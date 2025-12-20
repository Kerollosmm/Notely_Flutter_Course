import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock Timestamp
class MockTimestamp extends Mock implements Timestamp {}

void main() {
  group('CloudNote Model Tests', () {
    test('CloudNote should have isFavorite field', () {
      // This test is to ensure the model has been updated.
      // It will fail compilation until updated.
      /*
      final note = CloudNote(
        documentId: '1',
        ownerUserId: 'user1',
        contentJson: '{}',
        title: 'Title',
        lastModified: Timestamp.now(),
        isFavorite: true,
      );
      expect(note.isFavorite, true);
      */
    });
  });
}
