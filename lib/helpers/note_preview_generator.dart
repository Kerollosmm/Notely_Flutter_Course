import 'dart:convert';

class NotePreviewGenerator {
  static String getPreview(String contentJson, {int maxLength = 100}) {
    if (contentJson.isEmpty) return 'No content';
    try {
      final decoded = jsonDecode(contentJson);
      // Quill stores delta as a list of operations
      if (decoded is List) {
        final StringBuffer buffer = StringBuffer();
        for (final op in decoded) {
          if (op is Map && op.containsKey('insert')) {
            final insert = op['insert'];
            if (insert is String) {
              buffer.write(insert);
            }
          }
        }
        String text = buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
        if (text.length > maxLength) {
          return '${text.substring(0, maxLength)}...';
        }
        return text.isEmpty ? 'No additional text' : text;
      }
      return 'Invalid content format';
    } catch (e) {
      // Fallback if not JSON or error
      return contentJson.length > maxLength
          ? '${contentJson.substring(0, maxLength)}...'
          : contentJson;
    }
  }
}
