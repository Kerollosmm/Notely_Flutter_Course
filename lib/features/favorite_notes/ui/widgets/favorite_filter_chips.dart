import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';
import 'package:flutter_course_2/constants/text_styles.dart';

class FavoriteFilterChips extends StatefulWidget {
  final ValueChanged<String>? onSelected;
  const FavoriteFilterChips({super.key, this.onSelected});

  @override
  State<FavoriteFilterChips> createState() => _FavoriteFilterChipsState();
}

class _FavoriteFilterChipsState extends State<FavoriteFilterChips> {
  String selectedTag = 'All';
  final List<String> tags = ['All', 'Recent', 'Work', 'Personal'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTag == tag;
          return GestureDetector(
            onTap: () {
              setState(() => selectedTag = tag);
              widget.onSelected?.call(tag);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark
                          ? ColorsManager.darkSurface
                          : ColorsManager.lightSurface),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  tag,
                  style: isSelected
                      ? (isDark
                            ? TextStyles.font14BlackRegular
                            : TextStyles.font14WhiteRegular)
                      : (isDark
                            ? TextStyles.font14WhiteRegular
                            : TextStyles.font14BlackRegular),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
