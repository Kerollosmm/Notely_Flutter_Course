import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String contentJson;
  final String title;
  final Timestamp lastModified;
  final String category;
  final List<String> tags;
  final SyncStatus? syncStatus;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.contentJson,
    required this.title,
    required this.lastModified,
    this.category = 'All Notes',
    this.tags = const [],
    this.syncStatus,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerFieldUserId],
      contentJson =
          snapshot.data()[textFieldName] as String? ??
          '', // Mapping textFieldName to contentJson for now
      title = snapshot.data()[titleFieldName] as String? ?? '',
      lastModified =
          snapshot.data()['last_modified'] as Timestamp? ?? Timestamp.now(),
      category = snapshot.data()['category'] as String? ?? 'All Notes',
      tags = List<String>.from(snapshot.data()['tags'] ?? []),
      syncStatus = SyncStatus.synced; // Default to synced for Cloud
}
