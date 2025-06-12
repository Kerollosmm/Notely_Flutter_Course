import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

// Service class for managing notes in the database.
// This class provides an interface for all CRUD operations
// on notes and users, using a local SQLite database.
class NoteServices {
  Database? _db;

  // A cache of notes to provide quick access and reduce database queries.
  List<DatabaseNote> _notes = [];

  
  static final NoteServices _shared = NoteServices._sharedInstance();
  NoteServices._sharedInstance();
  factory NoteServices()=> _shared;
  // A stream controller to broadcast changes to the list of notes.
  // UI components can listen to this stream to reactively update.
  final _noteStreamControlle = StreamController<List<DatabaseNote>>.broadcast();

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // Populates the note cache from the database and notifies listeners.
  Future<void> _cacheNote() async {
    final allNote = await getAllNotes();
    _notes = allNote.toList();
    _noteStreamControlle.add(_notes);
  }

Stream<List<DatabaseNote>> get allNote => _noteStreamControlle.stream;
  // Updates an existing note in the database.
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String Text,
  }) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final UpdateCount = await db.update(noteTable, {
      textColumn: Text,
      isSyncedWithCloudColumn: 0,
    });
    if (UpdateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _noteStreamControlle.add(_notes);
      return updatedNote;
    }
  }

  // Retrieves all notes from the database.
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // Retrieves a single note by its ID.
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
      _noteStreamControlle.add(_notes);
      return note;
    }
  }

  // Deletes all notes from the database and clears the cache.
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final numberOfDeletian = await db.delete(noteTable);
    _notes = [];
    _noteStreamControlle.add(_notes);
    return numberOfDeletian;
  }

  // Deletes a note by its ID from the database and cache.
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      // optianal
      final countbefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      //optianl
      if (_notes.length != countbefore) {
        _noteStreamControlle.add(_notes);
      }
    }
  }

  // Creates a new note for a given user.
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';

    //create the Notes

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _noteStreamControlle.add(_notes);
    return note;
  }

  // Retrieves a user by their email.
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

  // Deletes a user from the database by their email.
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

  // Creates a new user in the database.
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
    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: id, email: email);
  }

  // Returns the database instance, or throws an error if it's not open.
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  // Closes the database connection.
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
      //EMPTY
    }
  }

  // Opens the database, creates tables if they don't exist, and caches notes.
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create user table
      await db.execute(createUserTable);

      //create Note table
      await db.execute(createNoteTable);
      await _cacheNote();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

// Represents a user in the database.
@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, dynamic> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;
  @override
  String toString() => 'person, ID  =$id, email= $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Column names for the 'user' table.
const idColumn = "id";
const emailColumn = "email";

// Represents a note in the database.
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, dynamic> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;

  @override
  String toString() =>
      'Note, ID = $id, User ID = $userId, Text = $text, Is Synced = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Database and table constants.
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
// Column names for the 'note' table.
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
// SQL statement to create the 'user' table.
const createUserTable = """CREATE TABLE IF NOT EXISTS "user" (
	   "id"	INTEGER NOT NULL UNIQUE,
	   "email"	TEXT NOT NULL UNIQUE,
	   PRIMARY KEY("id" AUTOINCREMENT)
   ) ;
""";
// SQL statement to create the 'note' table.
const createNoteTable = """CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL UNIQUE,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
""";
