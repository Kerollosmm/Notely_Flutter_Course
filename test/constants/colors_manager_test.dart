import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/constants/colors_manager.dart';

void main() {
  group('ColorsManager', () {
    test('should contain correct primary color', () {
      expect(ColorsManager.primary, const Color(0xFFF9F506));
    });

    test('should contain correct dark background color', () {
      expect(ColorsManager.darkBackground, const Color(0xFF23220F));
    });

    test('should contain correct light background variant', () {
      // Assuming a light/dark variant based on spec implication, though exact hex wasn't specified for light variant.
      // We will assert existance and non-nullity for now.
      expect(ColorsManager.lightBackground, isNotNull);
    });
  });
}
