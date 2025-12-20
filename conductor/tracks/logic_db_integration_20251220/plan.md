# Implementation Plan: Notely Logic & Database Integration

**Track ID:** `logic_db_integration_20251220`
**Status:** In Progress
**Workflow Reference:** `conductor/workflow.md`

---

## Phase 1: Design System Tokens & Constants [checkpoint: d7aa74e]
Goal: Implement the core theme tokens and navigation constants.

- [x] Task: Implement `ColorsManager` in `lib/constants/colors_manager.dart` 5191877
    - [x] Write tests for color retrieval/consistency
    - [x] Implement color constants (Primary, Dark BG, etc.)
- [x] Task: Implement `TextStyles` in `lib/constants/text_styles.dart` 5191877
    - [x] Write tests to verify typography settings (Spline Sans, Inter)
    - [x] Implement styles using `.sp` from `flutter_screenutil`
- [x] Task: Update `lib/constants/padge_routs.dart` with new route strings 5191877
    - [x] Add `/favourites`, `/settings`, `/account`, `/search`
- [x] Task: Conductor - User Manual Verification 'Design System Tokens & Constants' (Protocol in workflow.md) d7aa74e

---

## Phase 2: Database Schema & Migration
Goal: Upgrade `sqflite` schema to support Favorites and the Tagging System.

- [x] Task: Prepare Migration Tests a6697c3
    - [x] Write failing tests for DB version bump
    - [x] Write tests to verify `is_favorite` column exists after migration
    - [x] Write tests to verify `tags` and `note_tags` tables exist after migration
- [x] Task: Implement `is_favorite` migration in `NoteService` a6697c3
    - [x] Update `dbVersion` and `onUpgrade` logic
    - [x] Update `DatabaseNote` model to include `isFavorite`
- [x] Task: Implement Tagging System Tables a6697c3
    - [x] Create `tags` table (id, name)
    - [x] Create `note_tags` table (note_id, tag_id)
- [~] Task: Conductor - User Manual Verification 'Database Schema & Migration' (Protocol in workflow.md)

---

## Phase 3: Firestore Sync Integration
Goal: Sync Favorite status and Tags with Cloud Firestore.

- [ ] Task: Update `CloudNote` model and serialization
    - [ ] Write tests for `isFavorite` and `tags` serialization
    - [ ] Implement fields in `CloudNote` model
- [ ] Task: Update `FirebaseCloudStorage` logic
    - [ ] Write tests for pushing/pulling notes with favorites and tags
    - [ ] Update CRUD operations to include new fields in Firestore documents
- [ ] Task: Update `SyncService` mapping
    - [ ] Write tests for end-to-end sync of new fields
    - [ ] Map `is_favorite` and `tags` list in push/pull logic
- [ ] Task: Conductor - User Manual Verification 'Firestore Sync Integration' (Protocol in workflow.md)

---

## Phase 4: Repository Layer Extensions
Goal: Expose new features to the UI layer through the `NoteRepository`.

- [ ] Task: Implement Favorites Logic
    - [ ] Write tests for `toggleFavorite(id)` and `favoriteNotes` stream
    - [ ] Implement repository methods
- [ ] Task: Implement Tagging Logic
    - [ ] Write tests for `addTag`, `removeTag`, and `getTagsForNote`
    - [ ] Implement repository methods for tag management
- [ ] Task: Implement Enhanced Search
    - [ ] Write tests for searching by content AND tags
    - [ ] Implement repository search method
- [ ] Task: Conductor - User Manual Verification 'Repository Layer Extensions' (Protocol in workflow.md)
