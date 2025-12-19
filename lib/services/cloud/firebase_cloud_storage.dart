import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

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
    required Timestamp lastModified,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: contentJson,
        titleFieldName: title,
        'last_modified': lastModified,
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
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
