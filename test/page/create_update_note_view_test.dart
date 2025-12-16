import 'package:flutter/material.dart';
import 'package:flutter_course_2/page/create_update_note_view.dart';
import 'package:flutter_course_2/repositories/note_repository.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_update_note_view_test.mocks.dart';

@GenerateMocks([NoteRepository, AuthProvider])
void main() {
  late MockNoteRepository mockRepository;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockRepository = MockNoteRepository();
    mockAuthProvider = MockAuthProvider();
    // Inject mock auth provider into AuthService?
    // AuthService is a static proxy. We need to initialize it with the provider.
    // Assuming AuthService has a way to be initialized or we can just mock the calls if we could.
    // But AuthService.firebase() returns an instance.
    // Actually, `AuthService` delegates to `AuthProvider`.
    // Let's assume we can set the provider.
  });

  testWidgets('CreateUpdateNoteView renders title and editor', (WidgetTester tester) async {
    // Setup generic mock behavior
    // Since we can't easily swap `AuthService` static instance without modifying `AuthService` code,
    // we might have trouble if `createOrGetExistingNote` calls `AuthService.firebase().currentUser`.

    // However, if we pass an existing note via arguments, it shouldn't call currentUser immediately (except maybe for some checks).
    // Let's look at `createOrGetExistingNote`:
    // `final widgetNote = context.getArgument<DatabaseNote>();`
    // `if (widgetNote != null) ... return widgetNote;`
    // So if we pass a note, we bypass Auth check for creation.

    final note = DatabaseNote(
        id: 1,
        userId: 1,
        text: '{"title":"My Note","content":[{"insert":"Hello\\n"}]}',
        syncStatus: 1,
        lastModified: 1000
    );

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
            return MaterialPageRoute(
                settings: RouteSettings(arguments: note),
                builder: (context) => CreateUpdateNoteView(
                    noteRepository: mockRepository,
                ),
            );
        },
        home: Container(), // Dummy
      ),
    );

    // Navigate to the route with arguments
    // tester.push doesn't exist. We used pumpWidget above, so we are already 'at' the home.
    // However, the home was Container(). We want to push.

    // Instead of pushing, let's just pump the widget directly with the argument in context?
    // Hard to inject arguments without Navigator.

    // Better way: Re-pump the widget but this time `home` IS the view we want, wrapped in something that provides arguments?
    // Or just use the navigator key.

    // Simplified: Just pump the MaterialApp with 'home' being the CreateUpdateNoteView and inject arguments manually?
    // No, arguments come from ModalRoute.

    // Let's use onGenerateRoute properly which we did.
    // We just need to trigger the navigation.

    final BuildContext context = tester.element(find.byType(Container));
    Navigator.of(context).push(
         MaterialPageRoute(
            settings: RouteSettings(arguments: note),
            builder: (context) => CreateUpdateNoteView(
                noteRepository: mockRepository,
            ),
        ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Note'), findsOneWidget);
    expect(find.byType(quill.QuillEditor), findsOneWidget);
  });
}
