import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/enums/sync_status.dart';
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

  DatabaseUser? get currentUser => _user;

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

  Future<DatabaseUser> setFirebaseUid({
    required String email,
    required String firebaseUid,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final user = await getUser(email: email);

    await db.update(
      userTable,
      {firebaseUidColumn: firebaseUid},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return await getUser(email: email);
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    String? text,
    String? title,
    SyncStatus? syncStatus,
    String? remoteId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    final Map<String, dynamic> updates = {};
    if (text != null) updates[textColumn] = text;
    if (title != null) updates[titleColumn] = title;
    if (syncStatus != null) updates[syncStatusColumn] = syncStatus.index;
    if (remoteId != null) updates[remoteIdColumn] = remoteId;

    // Always update last modified
    updates[lastModifiedColumn] = DateTime.now().millisecondsSinceEpoch;

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

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
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

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    const title = '';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      titleColumn: title,
      syncStatusColumn: SyncStatus.dirty.index, // Created locally, so dirty
      lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      title: title,
      syncStatus: SyncStatus.dirty,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
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
      final db = await openDatabase(
        dbPath,
        version: 2, // Increment version for migration
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Migration logic

            // Add firebase_uid to user table
            try {
              await db.execute('ALTER TABLE user ADD COLUMN firebase_uid TEXT');
            } catch (e) {
              // Ignore if exists
            }

            // Add columns to note table
            try {
               await db.execute('ALTER TABLE note ADD COLUMN title TEXT DEFAULT ""');
            } catch (e) { /* ignore */ }

            try {
               await db.execute('ALTER TABLE note ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
            } catch (e) { /* ignore */ }

            try {
               await db.execute('ALTER TABLE note ADD COLUMN remote_id TEXT');
            } catch (e) { /* ignore */ }

            try {
               await db.execute('ALTER TABLE note ADD COLUMN last_modified INTEGER NOT NULL DEFAULT 0');
            } catch (e) { /* ignore */ }

            // Remove is_synced_with_cloud column if you want, but SQLite doesn't support DROP COLUMN easily.
            // We can just ignore it.
          }
        },
        onCreate: (db, version) async {
             // create the user table
            await db.execute(createUserTable);
            // create note table
            await db.execute(createNoteTable);
        }
      );
      _db = db;
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
  final String? firebaseUid;
  const DatabaseUser({
    required this.id,
    required this.email,
    this.firebaseUid,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String,
        firebaseUid = map[firebaseUidColumn] as String?;

  @override
  String toString() => 'Person, ID = $id, email = $email, firebaseUid = $firebaseUid';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final String title;
  final SyncStatus syncStatus;
  final String? remoteId;
  final int lastModified;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.title,
    required this.syncStatus,
    this.remoteId,
    required this.lastModified,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        title = (map[titleColumn] as String?) ?? '',
        syncStatus = SyncStatus.values[map[syncStatusColumn] as int],
        remoteId = map[remoteIdColumn] as String?,
        lastModified = map[lastModifiedColumn] as int;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, syncStatus = $syncStatus, text = $text, title = $title, remoteId = $remoteId, lastModified = $lastModified';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const firebaseUidColumn = 'firebase_uid';
const userIdColumn = 'user_id';
const textColumn = 'text';
const titleColumn = 'title';
const syncStatusColumn = 'sync_status';
const remoteIdColumn = 'remote_id';
const lastModifiedColumn = 'last_modified';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        "firebase_uid" TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
// I will drop the old table if it exists to force schema update for this task since I don't have versioning logic
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "title" TEXT,
        "sync_status"	INTEGER NOT NULL DEFAULT 0,
        "remote_id" TEXT,
        "last_modified" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
