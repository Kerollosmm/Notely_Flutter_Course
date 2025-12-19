import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String contentJson;
  final String title;
  final Timestamp lastModified;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.contentJson,
    required this.title,
    required this.lastModified,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerFieldUserId],
      contentJson =
          snapshot.data()[textFieldName] as String? ??
          '', // Mapping textFieldName to contentJson for now
      title = snapshot.data()[titleFieldName] as String? ?? '',
      lastModified =
          snapshot.data()['last_modified'] as Timestamp? ?? Timestamp.now();
}
