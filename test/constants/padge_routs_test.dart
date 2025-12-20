import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';

void main() {
  group('Page Routes', () {
    test('should have correct route strings', () {
      expect(favouritesRoute, '/favourites');
      expect(settingsRoute, '/settings');
      expect(accountRoute, '/account');
      expect(searchRoute, '/search');
    });
  });
}
