import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final CollectionReference<Map<String, dynamic>> notes;

  FirebaseCloudStorage._sharedInstance({FirebaseFirestore? firestore})
    : notes = (firestore ?? FirebaseFirestore.instance).collection('notes');

  static FirebaseCloudStorage? _shared;
  factory FirebaseCloudStorage({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      return FirebaseCloudStorage._sharedInstance(firestore: firestore);
    }
    return _shared ??= FirebaseCloudStorage._sharedInstance();
  }

  Stream<Iterable<CloudNote>> allNote({required String ownerUserId}) {
    return notes
        .where(ownerFieldUserId, isEqualTo: ownerUserId)
        .snapshots()
        .map(
          (event) =>
              event.docs.map((doc) => CloudNote.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNotes({
    required String documentId,
    required String contentJson,
    String title = '', // Optional for now
    bool? isFavorite,
    required Timestamp lastModified,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        textFieldName: contentJson,
        titleFieldName: title,
        'last_modified': lastModified,
      };
      if (isFavorite != null) {
        updates[isFavoriteFieldName] = isFavorite;
      }
      await notes.doc(documentId).update(updates);
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> updateFavoriteStatus({
    required String documentId,
    required bool isFavorite,
  }) async {
    try {
      await notes.doc(documentId).update({
        isFavoriteFieldName: isFavorite,
        'last_modified': Timestamp.now(),
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerFieldUserId, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // New method for Sync
  Future<Iterable<CloudNote>> getNotesModifiedAfter({
    required String ownerUserId,
    required Timestamp lastSynced,
  }) async {
    try {
      return await notes
          .where(ownerFieldUserId, isEqualTo: ownerUserId)
          .where('last_modified', isGreaterThan: lastSynced)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      // Index might be required
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> getFavoriteNotes({required String ownerUserId}) {
    return notes
        .where(ownerFieldUserId, isEqualTo: ownerUserId)
        .where(isFavoriteFieldName, isEqualTo: true)
        .snapshots()
        .map(
          (event) =>
              event.docs.map((doc) => CloudNote.fromSnapshot(doc)).toList(),
        );
  }

  Future<CloudNote> createNewNote({
    required String ownerUserId,
    required String contentJson,
    required Timestamp lastModified,
  }) async {
    final document = await notes.add({
      ownerFieldUserId: ownerUserId,
      textFieldName: contentJson,
      titleFieldName: '',
      'last_modified': lastModified,
    });
    final fitchNote = await document.get();
    return CloudNote(
      documentId: fitchNote.id,
      ownerUserId: ownerUserId,
      contentJson: contentJson,
      title: '',
      lastModified: lastModified,
      isFavorite: false,
    );
  }
}