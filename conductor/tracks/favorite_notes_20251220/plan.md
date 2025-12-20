# Track Plan: Implement the "Favorite Notes" Screen

## Phase 1: Data & Service Layer
Goal: Ensure the backend and service layers correctly handle "favorite" status and querying.

- [~] Task: Write Tests for Favorite Note Queries (Cloud & Local)
- [ ] Task: Implement `getFavoriteNotes` in `CloudFirestoreService`
- [ ] Task: Implement `toggleFavorite` logic in `NoteService`
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Data & Service Layer' (Protocol in workflow.md)

## Phase 2: Logic & State Management
Goal: Implement the Bloc to manage the favorites list, search, and filtering.

- [ ] Task: Write Unit Tests for `FavoriteNotesBloc`
- [ ] Task: Implement `FavoriteNotesBloc` (Events: Load, Search, Filter; States: Loading, Loaded, Error)
- [ ] Task: Integrate Bloc with `NoteRepository`
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Logic & State Management' (Protocol in workflow.md)

## Phase 3: UI Implementation
Goal: Build the responsive screen and components according to the design guidelines.

- [ ] Task: Write Widget Tests for `FavoriteNotesScreen`
- [ ] Task: Implement `FavoriteNotesScreen` Layout (Scaffold, AppBar)
- [ ] Task: Implement Search Bar and Filter Chips components
- [ ] Task: Implement Masonry Grid for Favorite Note Cards
- [ ] Task: Connect UI to `FavoriteNotesBloc`
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI Implementation' (Protocol in workflow.md)
