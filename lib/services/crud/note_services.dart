import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/extensions/list/filter.dart';
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
    int? syncStatus, // Optional: Update sync status
    String? remoteId, // Optional: Update remote ID
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    final updates = {
      textColumn: text,
      lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
    };

    // Default to dirty if not specified
    updates[syncStatusColumn] = syncStatus ?? 2; // 2 = Dirty

    if (remoteId != null) {
      updates[remoteIdColumn] = remoteId;
    }

    // update DB
    final updatesCount = await db.update(
      noteTable,
      updates,
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Only return notes that are not locally deleted (status 3)
    final notes = await db.query(
      noteTable,
      where: '$syncStatusColumn != ?',
      whereArgs: [3]
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // Method to get ALL notes including deleted ones (for sync service)
  Future<Iterable<DatabaseNote>> getAllNotesForSync() async {
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
      final notes = await db.query(noteTable);
      return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  // Soft delete for sync
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Update to deleted_locally status (3)
    final deletedCount = await db.update(
      noteTable,
      {
        syncStatusColumn: 3,
        lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  // Hard delete (for cleanup after sync)
  Future<void> hardDeleteNote({required int id}) async {
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
      final deletedCount = await db.delete(
          noteTable,
          where: 'id = ?',
          whereArgs: [id],
      );
      if (deletedCount == 0) {
          // It might have been already deleted
      } else {
          _notes.removeWhere((note) => note.id == id);
          _notesStreamController.add(_notes);
      }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      syncStatusColumn: 2, // 2 = Dirty (created locally)
      lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      syncStatus: 2,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> updateNoteSyncStatus({required int id, required int status, String? remoteId}) async {
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();

      final Map<String, dynamic> updates = {
          syncStatusColumn: status,
      };

      if (remoteId != null) {
          updates[remoteIdColumn] = remoteId;
      }

      await db.update(
          noteTable,
          updates,
          where: 'id = ?',
          whereArgs: [id],
      );

      // Update cache
      try {
        final note = await getNote(id: id);
        _notes.removeWhere((n) => n.id == id);
        _notes.add(note);
        _notesStreamController.add(_notes);
      } catch (e) {
        // Note might be hard deleted or not found
      }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final int syncStatus; // 1: Synced, 2: Dirty, 3: Deleted Locally
  final String? remoteId;
  final int lastModified;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.syncStatus,
    this.remoteId,
    required this.lastModified,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        syncStatus = map[syncStatusColumn] as int? ?? 1,
        remoteId = map[remoteIdColumn] as String?,
        lastModified = map[lastModifiedColumn] as int? ?? 0;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, syncStatus = $syncStatus, remoteId = $remoteId, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes_v2.db'; // Changed to avoid conflicts with old schema
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const syncStatusColumn = 'sync_status';
const remoteIdColumn = 'remote_id';
const lastModifiedColumn = 'last_modified';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "sync_status"	INTEGER NOT NULL DEFAULT 2,
        "remote_id"	TEXT UNIQUE,
        "last_modified"	INTEGER,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
