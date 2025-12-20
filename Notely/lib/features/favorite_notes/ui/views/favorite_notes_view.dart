import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_bloc.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_event.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_state.dart';
import 'package:flutter_course_2/features/favorite_notes/ui/widgets/favorite_header.dart';
import 'package:flutter_course_2/features/favorite_notes/ui/widgets/favorite_search_bar.dart';
import 'package:flutter_course_2/features/favorite_notes/ui/widgets/favorite_filter_chips.dart';
import 'package:flutter_course_2/features/favorite_notes/ui/widgets/favorite_note_grid.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';

class FavoriteNotesView extends StatelessWidget {
  const FavoriteNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ColorsManager.darkBackground
          : ColorsManager.lightBackground,
      body: SafeArea(
        child: BlocBuilder<FavoriteNotesBloc, FavoriteNotesState>(
          builder: (context, state) {
            if (state is FavoriteNotesStateLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FavoriteNotesStateLoaded) {
              // Apply local filtering based on searchTerm and activeTag
              final filteredNotes = state.notes.where((note) {
                final matchesSearch =
                    state.searchTerm.isEmpty ||
                    note.contentJson.toLowerCase().contains(
                      state.searchTerm.toLowerCase(),
                    );
                // For MVP, tags are not fully implemented in DatabaseNote,
                // so we just show all if 'All' is selected.
                final matchesTag = state.activeTag == 'All';
                return matchesSearch && matchesTag;
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const FavoriteHeader(),
                    SizedBox(height: 8.h),
                    FavoriteSearchBar(
                      onChanged: (value) {
                        context.read<FavoriteNotesBloc>().add(
                          FavoriteNotesEventSearch(value),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    FavoriteFilterChips(
                      onSelected: (tag) {
                        context.read<FavoriteNotesBloc>().add(
                          FavoriteNotesEventFilter(tag),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    if (filteredNotes.isEmpty)
                      _buildEmptyState(context)
                    else
                      FavoriteNoteGrid(
                        notes: filteredNotes,
                        onToggleFavorite: (id) {
                          context.read<FavoriteNotesBloc>().add(
                            FavoriteNotesEventToggleFavorite(id),
                          );
                        },
                      ),
                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              );
            }

            if (state is FavoriteNotesStateError) {
              return Center(child: Text('Error: ${state.exception}'));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(
            Icons.star_outline,
            size: 80.r,
            color: ColorsManager.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No favorite notes yet',
            style: Theme.of(context).brightness == Brightness.dark
                ? TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  )
                : TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start starring your important notes!',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
