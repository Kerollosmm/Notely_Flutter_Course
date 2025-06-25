import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNote({required String ownerUserId}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserId),
      );

  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNotes({
    required String documentId,
    required String title, // Added title
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title, // Added title
        textFieldName: text,
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

  Future<CloudNote> createNewNote({required String ownerUserId, String title = '', String text = ''}) async {
    final document = await notes.add({
      ownerFieldUserId: ownerUserId,
      titleFieldName: title, // Added title
      textFieldName: text,  // Used provided text or default
    });
    final fitchNote = await document.get();
    // Ensure data exists and fields are correctly typed, providing defaults if necessary
    final data = fitchNote.data();
    return CloudNote(
      documentId: fitchNote.id,
      ownerUserId: data?[ownerFieldUserId] as String? ?? ownerUserId, // Use fetched or fallback to input
      title: data?[titleFieldName] as String? ?? title,             // Use fetched or fallback to input
      text: data?[textFieldName] as String? ?? text,                // Use fetched or fallback to input
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
