import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';
import 'package:flutter_course_2/constants/text_styles.dart';

class FavoriteHeader extends StatelessWidget {
  const FavoriteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: 0.05,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.star, color: Colors.black),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Favorites',
                style: Theme.of(context).brightness == Brightness.dark
                    ? TextStyles.font24WhiteBold
                    : TextStyles.font24BlackBold,
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBO9UvgRdlDG2_W6OuA-Hp0P8b2CjDr14xg9llKQMONEA3dZfs9lGdTD3kOjaUqRYBPQ_6GWYRcfBdRjJUO0mF04EMpEPMzJOwA4GJuL2rRyxMkHyzWz2gloXTeGwpauvqs3s5syaxiEFy0ckfTTh4KYnjSp3wa5iGd8Qp84Uf7qu67BDxthKX9UvNGEqItr6PnNqwbpMW8wjqtA6-4CJOqBaYY_9TLIijSc8bpm4_qjEPrlKn0qZpsaNIazG6wUZbBR32gY0mH6ds',
            ),
          ),
        ],
      ),
    );
  }
}
