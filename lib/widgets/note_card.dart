import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloud/cloud_note.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../helpers/note_preview_generator.dart';

class NoteCard extends StatelessWidget {
  final CloudNote note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? searchQuery;

  const NoteCard({
    Key? key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF0F0F0)
                : const Color(0xFF2C2C2C),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (note.category != 'All Notes')
                  _buildCategoryBadge(note.category),
                Text(
                  _formatDate(note.lastModified),
                  style: AppTextStyles.bodyS,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildHighlightedText(
              note.title.isNotEmpty ? note.title : 'Untitled',
              searchQuery,
              AppTextStyles.h3,
              2,
            ),
            SizedBox(height: 8.h),
            _buildHighlightedText(
              NotePreviewGenerator.getPreview(note.contentJson),
              searchQuery,
              AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              4,
            ),
            if (note.tags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: note.tags.take(3).map((tag) => _buildTag(tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String? query, TextStyle style, int maxLines) {
    if (query == null || query.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    List<TextSpan> spans = [];
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
       if (index > start) {
         spans.add(TextSpan(text: text.substring(start, index), style: style));
       }
       spans.add(TextSpan(
         text: text.substring(index, index + query.length),
         style: style.copyWith(backgroundColor: AppColors.primary.withValues(alpha: 0.3), color: Colors.black),
       ));
       start = index + query.length;
       index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
       spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color bg = AppColors.tagWork;
    Color text = AppColors.tagWorkText;

    switch (category.toLowerCase()) {
      case 'personal':
        bg = AppColors.tagPersonal;
        text = AppColors.tagPersonalText;
        break;
      case 'study':
        bg = AppColors.tagStudy;
        text = AppColors.tagStudyText;
        break;
      case 'ideas':
        bg = AppColors.tagIdea;
        text = AppColors.tagIdeaText;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTextStyles.tag.copyWith(color: text),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        '#$tag',
        style: AppTextStyles.tag.copyWith(color: Colors.grey.shade600),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
