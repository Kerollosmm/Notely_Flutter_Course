
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String title; // Added title field
  final String text;
  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title, // Added to constructor
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerFieldUserId] as String, // Ensure type safety
        title = snapshot.data()[titleFieldName] as String? ?? '', // Read title, default to empty if null
        text = snapshot.data()[textFieldName] as String;
}