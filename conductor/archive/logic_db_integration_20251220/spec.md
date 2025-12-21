# Track Specification: Notely Logic & Database Integration

## 1. Overview
This track implements the core backend and logic updates required to support the new Notely UI. It focuses on establishing the design system tokens, updating the local database and cloud sync to support "Favorites" and a robust "Tagging System," and extending the repository layer to expose these features.

## 2. Functional Requirements

### 2.1 Theme Tokens & Constants
*   **ColorsManager**: centralized color definitions (Primary `#f9f506`, Dark BG `#23220f`, etc.).
*   **TextStyles**: centralized text styles using `google_fonts` (Spline Sans, Inter) and `flutter_screenutil`.
*   **Route Constants**: Define paths for `/favourites`, `/settings`, `/account`, and `/search`.

### 2.2 Database Layer (sqflite)
*   **Migration**: Upgrade DB version.
*   **Favorites**: Add `is_favorite` (INTEGER/BOOLEAN) column to the `note` table.
*   **Tagging System**:
    *   Create a new `tags` table (id, name).
    *   Create a new `note_tags` join table (note_id, tag_id).
    *   Update `DatabaseNote` model to include `isFavorite` and `List<String> tags`.

### 2.3 Cloud Sync (Firestore)
*   **Models**: Update `CloudNote` to include `isFavorite` and `tags`.
*   **Sync Logic**: Ensure `isFavorite` status and the associated `tags` are correctly pushed to and pulled from Firestore.

### 2.4 Repository Layer
*   **Methods**:
    *   `toggleFavorite(String noteId)`
    *   `getFavorites()` stream.
    *   `addTag(String noteId, String tagName)`
    *   `removeTag(String noteId, String tagName)`
    *   `getTagsForNote(String noteId)`
    *   `searchNotes(String query)` (filtering by content and tags).

## 3. Non-Functional Requirements
*   **Testing**: All new logic must be covered by unit tests (Target >80% coverage).
*   **Backward Compatibility**: Database migration must handle existing user data without data loss.
*   **Performance**: Tag queries should be efficient.

## 4. Acceptance Criteria
*   `ColorsManager` and `TextStyles` are implemented and importable.
*   Database migrates successfully on app launch.
*   Can toggle `isFavorite` on a note, and it persists locally and syncs to cloud.
*   Can create, assign, and remove tags from notes; changes persist and sync.
*   Unit tests pass for all new Service and Repository methods.

## 5. Out of Scope
*   UI implementation (Screens, Widgets) - to be handled in a subsequent track.
