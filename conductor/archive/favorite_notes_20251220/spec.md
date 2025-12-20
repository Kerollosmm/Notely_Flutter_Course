# Track Spec: Implement the "Favorite Notes" Screen

## Overview
This track focuses on creating a dedicated screen for users to view and manage their favorite (starred) notes. It includes real-time synchronization with Cloud Firestore, local caching for offline access, and a highly responsive UI with searching and filtering capabilities.

## User Stories
- As a user, I want to see all my starred notes in one place so I can quickly access important information.
- As a user, I want to search through my favorite notes to find specific content.
- As a user, I want to filter my favorites by tags (e.g., Work, Personal, School) to organize my view.
- As a user, I want to unstar a note directly from the favorites screen.

## Functional Requirements
### 1. Favorite Notes List
- Display a grid or list of notes that have the `is_favorite` flag set to true.
- Use a masonry-style grid layout as seen in the designs.
- Support real-time updates from Firestore.
- Display note title, snippet, tags, and a "star" icon indicating it's a favorite.

### 2. Search Functionality
- A search bar at the top of the screen to filter the displayed favorite notes by title or content.
- Real-time filtering as the user types.

### 3. Filter Chips
- Horizontal scrolling chips for categories (All, Recent, Work, Personal, etc.).
- Selecting a chip filters the favorites list by the corresponding tag.

### 4. Navigation
- Accessible via the "Saved" icon in the bottom navigation bar.
- Navigation back to the home screen or settings.

## Technical Requirements
- **State Management**: Use `FavoriteNotesBloc` to handle fetching, searching, and filtering states.
- **Data Layer**: Extend the existing `CloudStore` or `NoteService` to support querying specifically for favorites.
- **UI Components**: 
  - Use `flutter_screenutil` for all dimensions.
  - Follow the "Modern & Vibrant" aesthetic (Primary Color: `#f9f506`).
  - Implement both Light and Dark mode support.
- **Performance**: Ensure smooth scrolling and fast filtering (debounce search inputs).

## Design Considerations
- **Empty State**: Show a friendly illustration or message when no favorites exist.
- **Loading State**: Show shimmer effects or a loading spinner while fetching data.
- **Error Handling**: Display a snackbar or error widget if data fetching fails.
