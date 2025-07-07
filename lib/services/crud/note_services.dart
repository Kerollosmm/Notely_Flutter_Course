import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/extensions/list/filter.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
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
    required String title, // Added title parameter
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    // update DB
    final updatesCount = await db.update(
      noteTable,
      {
        textColumn: text,
        titleColumn: title, // Added title to update map
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      // Fetch the updated note to reflect changes
      final updatedLocalNote = await getNote(id: note.id);
      _notes.removeWhere((n) => n.id == updatedLocalNote.id);
      _notes.add(updatedLocalNote);
      _notesStreamController.add(_notes);
      return updatedLocalNote;
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
    const title = ''; // Default empty title for new notes
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      titleColumn: title, // Add title to insert map
      isSyncedWithCloudColumn: 0, // New local notes are not synced by default
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      title: title, // Add title to constructor
      isSyncedWithCloud: false, // New local notes are not synced by default
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

  Future<void> syncNotesWithCloud({required String userId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final allLocalNotes = await getAllNotes();
    final localNotesToSync = allLocalNotes.where((note) => !note.isSyncedWithCloud).toList();
    if (localNotesToSync.isEmpty) {
      return; // Nothing to sync
    }

    final cloudStorage = FirebaseCloudStorage();
    final db = _getDatabaseOrThrow();

    for (final localNote in localNotesToSync) {
      try {
        String? actualCloudDocId = localNote.cloudDocumentId;

        if (actualCloudDocId == null) {
          // New note: Create in Firebase, then update with content
          final newCloudNotePlaceholder = await cloudStorage.createNewNote(ownerUserId: userId);
          actualCloudDocId = newCloudNotePlaceholder.documentId;

          // Now update this new cloud note with local content
          await cloudStorage.updateNotes(
            documentId: actualCloudDocId,
            text: localNote.text,
            title: localNote.title,
          );
        } else {
          // Existing note, updated offline: Update in Firebase
          await cloudStorage.updateNotes(
            documentId: actualCloudDocId,
            text: localNote.text,
            title: localNote.title,
          );
        }

        // If cloud operations were successful, update local note
        await db.update(
          noteTable,
          {
            isSyncedWithCloudColumn: 1,
            cloudDocumentIdColumn: actualCloudDocId, // Store/confirm the cloud ID
          },
          where: 'id = ?',
          whereArgs: [localNote.id],
        );

        // Update the in-memory cache
        final index = _notes.indexWhere((note) => note.id == localNote.id);
        if (index != -1) {
          _notes[index] = DatabaseNote(
            id: localNote.id,
            userId: localNote.userId,
            text: localNote.text,
            title: localNote.title,
            isSyncedWithCloud: true,
            cloudDocumentId: actualCloudDocId, // Update with the correct cloud ID
          );
        }
      } catch (e) {
        print('Error syncing note ${localNote.id} to cloud: $e');
        // Optionally, implement more sophisticated error handling, like retry mechanisms
        // or leaving the note as unsynced.
      }
    }
    _notesStreamController.add(List.from(_notes)); // Notify listeners
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
  final String title;
  final bool isSyncedWithCloud;
  final String? cloudDocumentId; // Added cloudDocumentId field

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.title,
    required this.isSyncedWithCloud,
    this.cloudDocumentId, // Added cloudDocumentId field
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        title = map[titleColumn] as String? ?? '',
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1,
        cloudDocumentId = map[cloudDocumentIdColumn] as String?; // Added cloudDocumentId field

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, title = $title, isSyncedWithCloud = $isSyncedWithCloud, cloudDocumentId = $cloudDocumentId, text = $text';

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
const textColumn = 'text';
const titleColumn = 'title';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const cloudDocumentIdColumn = 'cloud_document_id'; // Added cloud document ID column constant

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "title" TEXT NOT NULL DEFAULT '',
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        "cloud_document_id" TEXT,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
