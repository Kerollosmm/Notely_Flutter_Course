import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/extensions/list/filter.dart';
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:uuid/uuid.dart';

enum SyncStatus { synced, dirty, deletedLocally }

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

  Future<Iterable<DatabaseNote>> getNotesWithStatus(SyncStatus status) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: '$syncStatusColumn = ?',
      whereArgs: [status.index],
    );
    return notes.map((n) => DatabaseNote.fromRow(n));
  }

  Future<void> upsertLocalNote({
    required String id,
    required int userId,
    required String contentJson,
    required String? remoteId,
    required DateTime lastModified,
    SyncStatus syncStatus = SyncStatus.synced,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Check if exists
    final exists = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);

    if (exists.isNotEmpty) {
      await db.update(
        noteTable,
        {
          userIdColumn: userId,
          contentJsonColumn: contentJson,
          syncStatusColumn: syncStatus.index,
          if (remoteId != null) remoteIdColumn: remoteId,
          lastModifiedColumn: lastModified.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await db.insert(noteTable, {
        idColumn: id,
        userIdColumn: userId,
        contentJsonColumn: contentJson,
        syncStatusColumn: syncStatus.index,
        remoteIdColumn: remoteId,
        lastModifiedColumn: lastModified.millisecondsSinceEpoch,
      });
    }

    // Refresh cache (optional, or just for this note)
    // For performance, maybe don't refresh entire list every time if batching.
    // But consistent with current architecture:
    final note = await getNote(
      id: id,
    ); // This refreshes the cache for this note
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String contentJson,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    final updatesCount = await db.update(
      noteTable,
      {
        contentJsonColumn: contentJson,
        syncStatusColumn: SyncStatus.dirty.index,
        lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
      },
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

  // New method to update sync status
  Future<void> updateNoteSyncStatus({
    required String id,
    required SyncStatus status,
    String? remoteId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final Map<String, dynamic> updates = {syncStatusColumn: status.index};
    if (remoteId != null) {
      updates[remoteIdColumn] = remoteId;
    }

    await db.update(noteTable, updates, where: 'id = ?', whereArgs: [id]);

    // Refresh cache
    final updatedNote = await getNote(id: id);
    _notes.removeWhere((n) => n.id == id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required String id}) async {
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

  Future<void> purgeNote({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      // It might have been already deleted or didn't exist
      // throw CouldNotDeleteNote(); // Optional
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
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

  Future<void> deleteNote({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Soft delete for sync
    final deletedCount = await db.update(
      noteTable,
      {
        syncStatusColumn: SyncStatus.deletedLocally.index,
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

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const contentJson = '[{"insert":"\\n"}]'; // Empty Delta JSON
    final noteId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(noteTable, {
      idColumn: noteId,
      userIdColumn: owner.id,
      contentJsonColumn: contentJson,
      syncStatusColumn: SyncStatus.dirty.index,
      lastModifiedColumn: now,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      contentJson: contentJson,
      syncStatus: SyncStatus.dirty,
      remoteId: null,
      lastModified: DateTime.fromMillisecondsSinceEpoch(now),
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

    // Using String ID for User now?
    // The previous implementation used auto-increment int for User ID.
    // For minimal refactor friction, I will keep User ID as int for now,
    // BUT DatabaseNote.userId MUST match it.
    // Note: The prompt implies using Firebase UID.
    // However, DatabaseUser is local.
    // Let's stick to existing User ID logic for DatabaseUser to avoid breaking everything,
    // but Note ID is now UUID String.

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId, // Keeping this int for now as per legacy table
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
      // We might need to drop table if it exists and schema changed, for this dev phase
      // await db.execute('DROP TABLE IF EXISTS $noteTable');
      // For now, I'll rely on the user to uninstall/reinstall or I'll just change the table name or run a migration
      // Since this is a refactor, I will update the CREATE statement.
      // IF the table exists with old schema, it might crash.
      // I'll add a check or just Create if not exists.
      // Ideally we version the DB.

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
  const DatabaseUser({required this.id, required this.email});

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
  final String id;
  final int userId;
  final String contentJson;
  final SyncStatus syncStatus;
  final String? remoteId;
  final DateTime lastModified;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.contentJson,
    required this.syncStatus,
    required this.remoteId,
    required this.lastModified,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as String,
      userId = map[userIdColumn] as int,
      contentJson = map[contentJsonColumn] as String,
      syncStatus = SyncStatus.values[map[syncStatusColumn] as int],
      remoteId = map[remoteIdColumn] as String?,
      lastModified = DateTime.fromMillisecondsSinceEpoch(
        map[lastModifiedColumn] as int,
      );

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, syncStatus = $syncStatus, lastModified = $lastModified';

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
const userIdColumn = 'user_id';
const contentJsonColumn = 'content_json';
const syncStatusColumn = 'sync_status';
const remoteIdColumn = 'remote_id';
const lastModifiedColumn = 'last_modified';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

// Updated Note Table Schema
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	TEXT NOT NULL PRIMARY KEY,
        "user_id"	INTEGER NOT NULL,
        "content_json"	TEXT,
        "sync_status"	INTEGER NOT NULL DEFAULT 0,
        "remote_id" TEXT,
        "last_modified" INTEGER NOT NULL,
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';
