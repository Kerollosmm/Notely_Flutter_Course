import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    Key? key,
    this.onSearchTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      titleSpacing: AppDimensions.paddingM,
      title: Row(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description,
              color: Colors.black,
              size: 20.w,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Notely',
            style: AppTextStyles.h2,
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            margin: EdgeInsets.only(right: AppDimensions.paddingM),
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600, size: 20.w),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          child: GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400, size: 24.w),
                  SizedBox(width: 12.w),
                  Text(
                    'Search your thoughts...',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120.h);
}
