import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_bloc.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_state.dart';
import 'package:flutter_course_2/features/favorite_notes/ui/views/favorite_notes_view.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'dart:io';
import 'dart:async';

class MockFavoriteNotesBloc extends Mock implements FavoriteNotesBloc {}

class MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(MockHttpClientRequest());
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() {
    return Future.value(MockHttpClientResponse());
  }
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 1;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final transparentGif = <int>[
      0x47,
      0x49,
      0x46,
      0x38,
      0x39,
      0x61,
      0x01,
      0x00,
      0x01,
      0x00,
      0x80,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x21,
      0xf9,
      0x04,
      0x01,
      0x00,
      0x00,
      0x00,
      0x00,
      0x2c,
      0x00,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x01,
      0x00,
      0x00,
      0x02,
      0x02,
      0x44,
      0x01,
      0x00,
      0x3b,
    ];
    return Stream<List<int>>.value(transparentGif).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class MockHttpHeaders extends Mock implements HttpHeaders {}

void main() {
  late FavoriteNotesBloc bloc;

  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  setUp(() {
    bloc = MockFavoriteNotesBloc();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const FavoriteNotesView(),
          ),
        );
      },
    );
  }

  testWidgets('displays loading indicator when state is loading', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const FavoriteNotesStateLoading());
    when(
      () => bloc.stream,
    ).thenAnswer((_) => Stream.value(const FavoriteNotesStateLoading()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays empty state when no notes are loaded', (tester) async {
    when(
      () => bloc.state,
    ).thenReturn(const FavoriteNotesStateLoaded(notes: []));
    when(() => bloc.stream).thenAnswer(
      (_) => Stream.value(const FavoriteNotesStateLoaded(notes: [])),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No favorite notes yet'), findsOneWidget);
  });

  testWidgets('displays grid of notes when notes are loaded', (tester) async {
    final notes = [
      DatabaseNote(
        id: '1234567890',
        userId: 1,
        contentJson: 'Note 1 Content',
        syncStatus: SyncStatus.synced,
        remoteId: 'r1',
        lastModified: DateTime.now(),
        isFavorite: true,
      ),
    ];
    when(() => bloc.state).thenReturn(FavoriteNotesStateLoaded(notes: notes));
    when(
      () => bloc.stream,
    ).thenAnswer((_) => Stream.value(FavoriteNotesStateLoaded(notes: notes)));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Note 1 Content'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsWidgets);
  });
}

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}
