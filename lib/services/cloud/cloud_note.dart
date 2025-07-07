import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_course_2/services/crud/note_services.dart' show isSyncedWithCloudColumn;

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;
  final bool isSyncedWithCloud;
  final String? cloudDocumentId; // Added field for actual Firebase document ID
  

  const CloudNote({
    required this.documentId, // This will be local DB ID string for notes from local DB
    required this.ownerUserId,
    required this.text,
    required this.title,
    required this.isSyncedWithCloud,
    this.cloudDocumentId, // Firebase document ID
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id, // This is the Firebase document ID when coming from Firestore
      ownerUserId = snapshot.data()[ownerFieldUserId],
      text = snapshot.data()[textFieldName] as String,
      title = snapshot.data()[titleFieldName] as String,
      isSyncedWithCloud = snapshot.data()[isSyncedWithCloudColumn] as bool? ?? true,
      // When fetching directly from Firestore, this note *is* the cloud canonical version.
      // So its own documentId is its cloudDocumentId.
      cloudDocumentId = snapshot.id;
}
