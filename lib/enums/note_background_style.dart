enum NoteBackgroundStyle {
  plain,
  ruledLines,
  gridLines,
}

// Helper to convert enum to string and back for storage
String noteBackgroundStyleToString(NoteBackgroundStyle style) {
  return style.toString().split('.').last;
}

NoteBackgroundStyle stringToNoteBackgroundStyle(String? styleString) {
  if (styleString == null) return NoteBackgroundStyle.plain;
  try {
    return NoteBackgroundStyle.values.firstWhere(
      (e) => noteBackgroundStyleToString(e) == styleString,
    );
  } catch (e) {
    return NoteBackgroundStyle.plain; // Default if string is invalid
  }
}
