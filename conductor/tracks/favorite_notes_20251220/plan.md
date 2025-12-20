# Track Plan: Implement the "Favorite Notes" Screen

## Phase 1: Data & Service Layer [checkpoint: fb8d49c]
Goal: Ensure the backend and service layers correctly handle "favorite" status and querying.

- [x] Task: Write Tests for Favorite Note Queries (Cloud & Local) (37fa385)
- [x] Task: Implement `getFavoriteNotes` in `CloudFirestoreService` (37fa385)
- [x] Task: Implement `toggleFavorite` logic in `NoteService` (37fa385)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Data & Service Layer' (Protocol in workflow.md) (fb8d49c)

## Phase 2: Logic & State Management [checkpoint: 2d2a1a8]
Goal: Implement the Bloc to manage the favorites list, search, and filtering.

- [x] Task: Write Unit Tests for `FavoriteNotesBloc` (92e69f9)
- [x] Task: Implement `FavoriteNotesBloc` (Events: Load, Search, Filter; States: Loading, Loaded, Error) (92e69f9)
- [x] Task: Integrate Bloc with `NoteRepository` (92e69f9)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Logic & State Management' (Protocol in workflow.md) (2d2a1a8)

## Phase 3: UI Implementation
Goal: Build the responsive screen and components according to the design guidelines.

- [ ] Task: Write Widget Tests for `FavoriteNotesScreen`
- [ ] Task: Implement `FavoriteNotesScreen` Layout (Scaffold, AppBar)
- [ ] Task: Implement Search Bar and Filter Chips components
- [ ] Task: Implement Masonry Grid for Favorite Note Cards
- [ ] Task: Connect UI to `FavoriteNotesBloc`
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI Implementation' (Protocol in workflow.md)
