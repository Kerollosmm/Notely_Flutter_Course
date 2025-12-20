import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';
import 'package:flutter_course_2/constants/text_styles.dart';

class FavoriteNoteGrid extends StatelessWidget {
  final List<DatabaseNote> notes;
  final Function(String) onToggleFavorite;
  const FavoriteNoteGrid({
    super.key,
    required this.notes,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        itemCount: notes.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final note = notes[index];
          return _NoteCard(
            note: note,
            onToggleFavorite: () => onToggleFavorite(note.id),
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final DatabaseNote note;
  final VoidCallback onToggleFavorite;
  const _NoteCard({required this.note, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Simple parsing for title/content from contentJson (assuming Delta format for now or plain text)
    // In a real app we'd use flutter_quill to parse
    final content = note.contentJson; // Placeholder

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface : ColorsManager.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: ColorsManager.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ColorsManager.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Note',
                  style: TextStyles.font12GrayRegular.copyWith(
                    color: isDark
                        ? ColorsManager.primary
                        : ColorsManager.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggleFavorite,
                icon: Icon(
                  Icons.star,
                  color: ColorsManager.primary,
                  size: 20.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Note ID: ${note.id.length > 8 ? note.id.substring(0, 8) : note.id}',
            style: isDark
                ? TextStyles.font16WhiteRegular
                : TextStyles.font16BlackRegular,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyles.font14GrayRegular,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
