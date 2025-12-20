import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';
import 'package:flutter_course_2/constants/text_styles.dart';

class FavoriteSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const FavoriteSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? ColorsManager.darkSurface
              : ColorsManager.lightSurface,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          style: isDark
              ? TextStyles.font16WhiteRegular
              : TextStyles.font16BlackRegular,
          decoration: InputDecoration(
            hintText: 'Search favorites...',
            hintStyle: TextStyles.font16HintRegular,
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? ColorsManager.primary : ColorsManager.primaryDark,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        ),
      ),
    );
  }
}
