// Cloud Features Integration Test Suite
// Tests: Firebase Auth, Cloud Firestore, and Sync Service
//
// Run with: flutter test test/cloud_features_test.dart
// Note: These tests use MOCK implementations to avoid hitting real Firebase.
// For true integration tests, use Firebase Emulators.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';

// ==============================================================================
// MOCK IMPLEMENTATIONS
// ==============================================================================

/// Mock Auth Provider - Simulates Firebase Auth behavior
class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Simulated user database
  final Map<String, String> _registeredUsers = {};

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    // Validate email format
    if (!email.contains('@')) {
      throw InvalidEmailAuthExceptions();
    }

    // Check password strength
    if (password.length < 6) {
      throw WeakPasswordAuthExceptions();
    }

    // Check if user already exists
    if (_registeredUsers.containsKey(email)) {
      throw EmailAlreadyInUseAuthExceptions();
    }

    // Register user
    _registeredUsers[email] = password;

    final user = AuthUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      isEmailVerified: false,
      email: email,
    );
    _user = user;
    return user;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    // Check if user exists
    if (!_registeredUsers.containsKey(email)) {
      throw UserNotFoundAuthExceptions();
    }

    // Check password
    if (_registeredUsers[email] != password) {
      throw WrongPasswordAuthException();
    }

    final user = AuthUser(
      id: 'user_${email.hashCode}',
      isEmailVerified: false,
      email: email,
    );
    _user = user;
    return user;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoginAuthExceptions();
    await Future.delayed(const Duration(milliseconds: 50));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoginAuthExceptions();

    // Simulate email verification
    _user = AuthUser(id: _user!.id, isEmailVerified: true, email: _user!.email);
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!isInitialized) throw NotInitializedException();

    if (!toEmail.contains('@')) {
      throw InvalidEmailAuthExceptions();
    }

    if (!_registeredUsers.containsKey(toEmail)) {
      throw UserNotFoundAuthExceptions();
    }

    // Simulate sending email (no actual action needed)
  }
}

class NotInitializedException implements Exception {}

/// Mock Cloud Storage - Simulates Firestore behavior
class MockCloudStorage {
  final Map<String, MockCloudNote> _notes = {};
  int _documentIdCounter = 0;

  Stream<Iterable<MockCloudNote>> allNote({required String ownerUserId}) {
    return Stream.value(
      _notes.values.where((note) => note.ownerUserId == ownerUserId),
    );
  }

  Future<MockCloudNote> createNewNote({required String ownerUserId}) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final docId = 'doc_${++_documentIdCounter}';
    final note = MockCloudNote(
      documentId: docId,
      ownerUserId: ownerUserId,
      text: '',
      title: '',
    );
    _notes[docId] = note;
    return note;
  }

  Future<void> updateNotes({
    required String documentId,
    required String text,
    required String title,
  }) async {
    if (!_notes.containsKey(documentId)) {
      throw CouldNotUpdateNoteException();
    }

    final existing = _notes[documentId]!;
    _notes[documentId] = MockCloudNote(
      documentId: documentId,
      ownerUserId: existing.ownerUserId,
      text: text,
      title: title,
    );
  }

  Future<void> deleteNotes({required String documentId}) async {
    if (!_notes.containsKey(documentId)) {
      throw CouldNotDeleteNoteException();
    }
    _notes.remove(documentId);
  }

  Future<Iterable<MockCloudNote>> getNotes({
    required String ownerUserId,
  }) async {
    return _notes.values.where((note) => note.ownerUserId == ownerUserId);
  }

  // Helper for testing
  int get noteCount => _notes.length;
  void clear() => _notes.clear();
}

class MockCloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;

  const MockCloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.title,
  });
}

// ==============================================================================
// TEST SUITE
// ==============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // PART 1: Firebase Authentication Tests
  // ---------------------------------------------------------------------------
  group('🔐 Firebase Authentication Service', () {
    late MockAuthProvider authProvider;

    setUp(() {
      authProvider = MockAuthProvider();
    });

    group('Initialization', () {
      test('Should NOT be initialized at start', () {
        expect(authProvider.isInitialized, false);
      });

      test('Should initialize successfully', () async {
        await authProvider.initialize();
        expect(authProvider.isInitialized, true);
      });

      test('Current user should be null after initialization', () async {
        await authProvider.initialize();
        expect(authProvider.currentUser, null);
      });
    });

    group('User Registration (createUser)', () {
      setUp(() async {
        await authProvider.initialize();
      });

      test('✅ Should create user with valid email/password', () async {
        final user = await authProvider.createUser(
          email: 'test@example.com',
          password: 'securePassword123',
        );

        expect(user, isNotNull);
        expect(user.email, 'test@example.com');
        expect(user.isEmailVerified, false);
        expect(authProvider.currentUser, user);
      });

      test('❌ Should throw WeakPasswordAuthExceptions for short password', () {
        expect(
          () => authProvider.createUser(
            email: 'test@example.com',
            password: '123', // Too short
          ),
          throwsA(isA<WeakPasswordAuthExceptions>()),
        );
      });

      test('❌ Should throw InvalidEmailAuthExceptions for invalid email', () {
        expect(
          () => authProvider.createUser(
            email: 'invalid-email', // Missing @
            password: 'securePassword123',
          ),
          throwsA(isA<InvalidEmailAuthExceptions>()),
        );
      });

      test(
        '❌ Should throw EmailAlreadyInUseAuthExceptions for duplicate email',
        () async {
          await authProvider.createUser(
            email: 'duplicate@example.com',
            password: 'password123',
          );

          expect(
            () => authProvider.createUser(
              email: 'duplicate@example.com',
              password: 'differentPassword',
            ),
            throwsA(isA<EmailAlreadyInUseAuthExceptions>()),
          );
        },
      );
    });

    group('User Login (logIn)', () {
      setUp(() async {
        await authProvider.initialize();
        // Pre-register a user
        await authProvider.createUser(
          email: 'existing@example.com',
          password: 'correctPassword',
        );
        await authProvider.logOut();
      });

      test('✅ Should login with correct credentials', () async {
        final user = await authProvider.logIn(
          email: 'existing@example.com',
          password: 'correctPassword',
        );

        expect(user, isNotNull);
        expect(user.email, 'existing@example.com');
        expect(authProvider.currentUser, user);
      });

      test(
        '❌ Should throw UserNotFoundAuthExceptions for non-existent user',
        () {
          expect(
            () => authProvider.logIn(
              email: 'nonexistent@example.com',
              password: 'anyPassword',
            ),
            throwsA(isA<UserNotFoundAuthExceptions>()),
          );
        },
      );

      test('❌ Should throw WrongPasswordAuthException for wrong password', () {
        expect(
          () => authProvider.logIn(
            email: 'existing@example.com',
            password: 'wrongPassword',
          ),
          throwsA(isA<WrongPasswordAuthException>()),
        );
      });
    });

    group('Logout (logOut)', () {
      setUp(() async {
        await authProvider.initialize();
      });

      test('✅ Should logout successfully when logged in', () async {
        await authProvider.createUser(
          email: 'user@example.com',
          password: 'password123',
        );
        expect(authProvider.currentUser, isNotNull);

        await authProvider.logOut();
        expect(authProvider.currentUser, null);
      });

      test('❌ Should throw UserNotLoginAuthExceptions when not logged in', () {
        expect(
          () => authProvider.logOut(),
          throwsA(isA<UserNotLoginAuthExceptions>()),
        );
      });
    });

    group('Email Verification (sendEmailVerification)', () {
      setUp(() async {
        await authProvider.initialize();
      });

      test('✅ Should verify email when logged in', () async {
        await authProvider.createUser(
          email: 'verify@example.com',
          password: 'password123',
        );
        expect(authProvider.currentUser!.isEmailVerified, false);

        await authProvider.sendEmailVerification();
        expect(authProvider.currentUser!.isEmailVerified, true);
      });

      test('❌ Should throw when not logged in', () {
        expect(
          () => authProvider.sendEmailVerification(),
          throwsA(isA<UserNotLoginAuthExceptions>()),
        );
      });
    });

    group('Password Reset (sendPasswordReset)', () {
      setUp(() async {
        await authProvider.initialize();
        await authProvider.createUser(
          email: 'reset@example.com',
          password: 'oldPassword',
        );
        await authProvider.logOut();
      });

      test('✅ Should send reset email for existing user', () async {
        // Should complete without error
        await authProvider.sendPasswordReset(toEmail: 'reset@example.com');
      });

      test('❌ Should throw InvalidEmailAuthExceptions for invalid email', () {
        expect(
          () => authProvider.sendPasswordReset(toEmail: 'invalid-email'),
          throwsA(isA<InvalidEmailAuthExceptions>()),
        );
      });

      test(
        '❌ Should throw UserNotFoundAuthExceptions for non-existent user',
        () {
          expect(
            () =>
                authProvider.sendPasswordReset(toEmail: 'unknown@example.com'),
            throwsA(isA<UserNotFoundAuthExceptions>()),
          );
        },
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PART 2: Cloud Firestore Storage Tests
  // ---------------------------------------------------------------------------
  group('☁️ Cloud Firestore Storage Service', () {
    late MockCloudStorage cloudStorage;
    const testUserId = 'test_user_123';

    setUp(() {
      cloudStorage = MockCloudStorage();
    });

    tearDown(() {
      cloudStorage.clear();
    });

    group('Create Note (createNewNote)', () {
      test('✅ Should create a new empty note', () async {
        final note = await cloudStorage.createNewNote(ownerUserId: testUserId);

        expect(note.documentId, isNotEmpty);
        expect(note.ownerUserId, testUserId);
        expect(note.text, isEmpty);
        expect(note.title, isEmpty);
        expect(cloudStorage.noteCount, 1);
      });

      test('✅ Should create multiple notes for same user', () async {
        await cloudStorage.createNewNote(ownerUserId: testUserId);
        await cloudStorage.createNewNote(ownerUserId: testUserId);
        await cloudStorage.createNewNote(ownerUserId: testUserId);

        expect(cloudStorage.noteCount, 3);
      });

      test('✅ Each note should have unique document ID', () async {
        final note1 = await cloudStorage.createNewNote(ownerUserId: testUserId);
        final note2 = await cloudStorage.createNewNote(ownerUserId: testUserId);

        expect(note1.documentId, isNot(equals(note2.documentId)));
      });
    });

    group('Update Note (updateNotes)', () {
      test('✅ Should update note text and title', () async {
        final note = await cloudStorage.createNewNote(ownerUserId: testUserId);

        await cloudStorage.updateNotes(
          documentId: note.documentId,
          text: 'Updated content',
          title: 'Updated title',
        );

        final notes = await cloudStorage.getNotes(ownerUserId: testUserId);
        final updatedNote = notes.first;

        expect(updatedNote.text, 'Updated content');
        expect(updatedNote.title, 'Updated title');
      });

      test(
        '❌ Should throw CouldNotUpdateNoteException for non-existent note',
        () {
          expect(
            () => cloudStorage.updateNotes(
              documentId: 'non_existent_id',
              text: 'text',
              title: 'title',
            ),
            throwsA(isA<CouldNotUpdateNoteException>()),
          );
        },
      );
    });

    group('Delete Note (deleteNotes)', () {
      test('✅ Should delete existing note', () async {
        final note = await cloudStorage.createNewNote(ownerUserId: testUserId);
        expect(cloudStorage.noteCount, 1);

        await cloudStorage.deleteNotes(documentId: note.documentId);
        expect(cloudStorage.noteCount, 0);
      });

      test(
        '❌ Should throw CouldNotDeleteNoteException for non-existent note',
        () {
          expect(
            () => cloudStorage.deleteNotes(documentId: 'non_existent_id'),
            throwsA(isA<CouldNotDeleteNoteException>()),
          );
        },
      );
    });

    group('Get Notes (getNotes)', () {
      test('✅ Should return only notes for specific user', () async {
        const user1 = 'user_1';
        const user2 = 'user_2';

        await cloudStorage.createNewNote(ownerUserId: user1);
        await cloudStorage.createNewNote(ownerUserId: user1);
        await cloudStorage.createNewNote(ownerUserId: user2);

        final user1Notes = await cloudStorage.getNotes(ownerUserId: user1);
        final user2Notes = await cloudStorage.getNotes(ownerUserId: user2);

        expect(user1Notes.length, 2);
        expect(user2Notes.length, 1);
      });

      test('✅ Should return empty list for user with no notes', () async {
        final notes = await cloudStorage.getNotes(ownerUserId: 'unknown_user');
        expect(notes, isEmpty);
      });
    });

    group('Stream Notes (allNote)', () {
      test('✅ Should stream notes for specific user', () async {
        await cloudStorage.createNewNote(ownerUserId: testUserId);
        await cloudStorage.createNewNote(ownerUserId: testUserId);

        final stream = cloudStorage.allNote(ownerUserId: testUserId);
        final notes = await stream.first;

        expect(notes.length, 2);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PART 3: Integration Scenarios
  // ---------------------------------------------------------------------------
  group('🔄 Integration Scenarios', () {
    late MockAuthProvider authProvider;
    late MockCloudStorage cloudStorage;

    setUp(() async {
      authProvider = MockAuthProvider();
      cloudStorage = MockCloudStorage();
      await authProvider.initialize();
    });

    test(
      '✅ Complete user flow: Register -> Create Note -> Update -> Delete',
      () async {
        // 1. Register user
        final user = await authProvider.createUser(
          email: 'flow@example.com',
          password: 'password123',
        );
        expect(user, isNotNull);

        // 2. Verify email
        await authProvider.sendEmailVerification();
        expect(authProvider.currentUser!.isEmailVerified, true);

        // 3. Create a note
        final note = await cloudStorage.createNewNote(ownerUserId: user.id);
        expect(note, isNotNull);

        // 4. Update the note
        await cloudStorage.updateNotes(
          documentId: note.documentId,
          text: 'My first note content',
          title: 'My First Note',
        );

        // 5. Verify update
        final notes = await cloudStorage.getNotes(ownerUserId: user.id);
        expect(notes.first.title, 'My First Note');

        // 6. Delete the note
        await cloudStorage.deleteNotes(documentId: note.documentId);
        final remainingNotes = await cloudStorage.getNotes(
          ownerUserId: user.id,
        );
        expect(remainingNotes, isEmpty);

        // 7. Logout
        await authProvider.logOut();
        expect(authProvider.currentUser, null);
      },
    );

    test(
      '✅ Multi-user isolation: Users cannot access each other\'s notes',
      () async {
        // Create two users
        final user1 = await authProvider.createUser(
          email: 'alice@example.com',
          password: 'password123',
        );
        await authProvider.logOut();

        final user2 = await authProvider.createUser(
          email: 'bob@example.com',
          password: 'password456',
        );

        // Create notes for each user
        await cloudStorage.createNewNote(ownerUserId: user1.id);
        await cloudStorage.createNewNote(ownerUserId: user1.id);
        await cloudStorage.createNewNote(ownerUserId: user2.id);

        // Verify isolation
        final aliceNotes = await cloudStorage.getNotes(ownerUserId: user1.id);
        final bobNotes = await cloudStorage.getNotes(ownerUserId: user2.id);

        expect(aliceNotes.length, 2);
        expect(bobNotes.length, 1);

        // Notes are distinct
        for (final aliceNote in aliceNotes) {
          expect(aliceNote.ownerUserId, user1.id);
        }
        for (final bobNote in bobNotes) {
          expect(bobNote.ownerUserId, user2.id);
        }
      },
    );
  });
}
