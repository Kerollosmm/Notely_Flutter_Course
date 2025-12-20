import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/constants/text_styles.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';

void main() {
  group('TextStyles', () {
    testWidgets('should utilize Spline Sans for headers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return const MaterialApp(home: Scaffold());
          },
        ),
      );

      final style = TextStyles.font32PrimaryBold;
      expect(style.fontFamily, contains('SplineSans'));
      expect(style.fontWeight, FontWeight.bold);
      expect(style.color, ColorsManager.primary);
    });

    testWidgets('should utilize Inter for body text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return const MaterialApp(home: Scaffold());
          },
        ),
      );

      final style = TextStyles.font16WhiteRegular;
      expect(style.fontFamily, contains('Inter'));
      expect(style.fontWeight, FontWeight.normal);
      expect(style.color, ColorsManager.darkOnBackground);
    });
  });
}
