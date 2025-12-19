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
          // Instead of throwing, just return false or empty if user not set
          // But strict mode says throw.
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
    String category = 'Personal',
    List<String> tags = const [],
    SyncStatus syncStatus = SyncStatus.synced,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Check if exists
    final exists = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);

    final data = {
      userIdColumn: userId,
      contentJsonColumn: contentJson,
      syncStatusColumn: syncStatus.index,
      if (remoteId != null) remoteIdColumn: remoteId,
      lastModifiedColumn: lastModified.millisecondsSinceEpoch,
      categoryColumn: category,
      tagsColumn: jsonEncode(tags),
    };

    if (exists.isNotEmpty) {
      await db.update(
        noteTable,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      data[idColumn] = id;
      await db.insert(noteTable, data);
    }

    final note = await getNote(id: id);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    String? contentJson,
    String? category,
    List<String>? tags,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final Map<String, Object?> updates = {
      syncStatusColumn: SyncStatus.dirty.index,
      lastModifiedColumn: DateTime.now().millisecondsSinceEpoch,
    };
    if (contentJson != null) updates[contentJsonColumn] = contentJson;
    if (category != null) updates[categoryColumn] = category;
    if (tags != null) updates[tagsColumn] = jsonEncode(tags);

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

    final updatedNote = await getNote(id: id);
    _notes.removeWhere((n) => n.id == id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
  }

  Future<void> batchUpdateSyncStatuses(
    List<(String id, SyncStatus status, String? remoteId)> updates,
  ) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final batch = db.batch();

    for (final update in updates) {
      final id = update.$1;
      final status = update.$2;
      final remoteId = update.$3;

      final Map<String, dynamic> data = {syncStatusColumn: status.index};
      if (remoteId != null) {
        data[remoteIdColumn] = remoteId;
      }
      batch.update(noteTable, data, where: 'id = ?', whereArgs: [id]);
    }

    await batch.commit(noResult: true);
    // Refresh cache completely or selectively
    await _cacheNotes();
  }

  Future<void> batchUpsertNotes(List<DatabaseNote> notes) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final batch = db.batch();

    for (final note in notes) {
      final data = {
        idColumn: note.id,
        userIdColumn: note.userId,
        contentJsonColumn: note.contentJson,
        syncStatusColumn: note.syncStatus.index,
        if (note.remoteId != null) remoteIdColumn: note.remoteId,
        lastModifiedColumn: note.lastModified.millisecondsSinceEpoch,
        categoryColumn: note.category,
        tagsColumn: jsonEncode(note.tags),
      };

      // We use Insert with Conflict Replace usually, but here we want to update if exists.
      // SQFLite insert with conflictAlgorithm: ConflictAlgorithm.replace
      batch.insert(
        noteTable,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    await _cacheNotes();
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
      // throw CouldNotDeleteNote();
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

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    String category = 'Personal',
    List<String> tags = const [],
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const contentJson = '[{"insert":"\\n"}]';
    final noteId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(noteTable, {
      idColumn: noteId,
      userIdColumn: owner.id,
      contentJsonColumn: contentJson,
      syncStatusColumn: SyncStatus.dirty.index,
      lastModifiedColumn: now,
      categoryColumn: category,
      tagsColumn: jsonEncode(tags),
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      contentJson: contentJson,
      syncStatus: SyncStatus.dirty,
      remoteId: null,
      lastModified: DateTime.fromMillisecondsSinceEpoch(now),
      category: category,
      tags: tags,
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
      // throw DatabaseIsNotOpen(); // Relaxed: allow redundant close
    } else {
      await db.close();
      _db = null;
      _user = null; // Clear user on close
      _notes = []; // Clear cache on close
      _notesStreamController.add([]); // Notify stream
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
        version: 2, // Bump version
        onUpgrade: (db, oldVersion, newVersion) async {
           if (oldVersion < 2) {
             // Add new columns
             await db.execute("ALTER TABLE $noteTable ADD COLUMN $categoryColumn TEXT DEFAULT 'Personal'");
             await db.execute("ALTER TABLE $noteTable ADD COLUMN $tagsColumn TEXT DEFAULT '[]'");
           }
        },
        onCreate: (db, version) async {
          await db.execute(createUserTable);
          await db.execute(createNoteTable);
        },
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
  final String category;
  final List<String> tags;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.contentJson,
    required this.syncStatus,
    required this.remoteId,
    required this.lastModified,
    required this.category,
    required this.tags,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as String,
      userId = (map[userIdColumn] as num).toInt(),
      contentJson = map[contentJsonColumn] as String,
      syncStatus = SyncStatus.values[(map[syncStatusColumn] as num).toInt()],
      remoteId = map[remoteIdColumn] as String?,
      lastModified = DateTime.fromMillisecondsSinceEpoch(
        (map[lastModifiedColumn] as num).toInt(),
      ),
      category = (map[categoryColumn] as String?) ?? 'Personal',
      tags = _parseTags(map[tagsColumn] as String?);

  static List<String> _parseTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(tagsJson));
    } catch (_) {
      return [];
    }
  }

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
const categoryColumn = 'category';
const tagsColumn = 'tags';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	TEXT NOT NULL PRIMARY KEY,
        "user_id"	INTEGER NOT NULL,
        "content_json"	TEXT,
        "sync_status"	INTEGER NOT NULL DEFAULT 0,
        "remote_id" TEXT,
        "last_modified" INTEGER NOT NULL,
        "category" TEXT DEFAULT 'Personal',
        "tags" TEXT DEFAULT '[]',
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';
