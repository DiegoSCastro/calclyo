import 'package:calclyo/src/features/search/recents_repository.dart';
import 'package:calclyo/src/features/search/search_cubit.dart';
import 'package:calclyo/src/shell/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SearchView shows recents, filters live, and shows empty state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'search.recents.v1': <String>['percent'],
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = SearchCubit(recents: RecentsRepository(preferences: prefs));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SearchCubit>.value(
          value: cubit,
          child: const SearchView(),
        ),
      ),
    );
    // Pump twice: once for SharedPreferences, once for recents load.
    await tester.pump();
    await tester.pump();

    // Cold state: query empty → recents list with the seeded entry.
    expect(find.text('percent'), findsOneWidget);
    expect(find.text('RECENT SEARCHES'), findsOneWidget);
    expect(find.text('Start typing to find a calculator'), findsNothing);

    // Type a query that matches a real calculator.
    await tester.enterText(find.byType(TextField), 'tip');
    await tester.pump();
    expect(find.text('Tip'), findsOneWidget);
    expect(
      find.text('Tip amount and total from bill and percentage'),
      findsOneWidget,
    );
    // The recents header should disappear now that we have an active query.
    expect(find.text('RECENT SEARCHES'), findsNothing);

    // Type a query that has no matches → empty state.
    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump();
    expect(find.text('No results for "zzzzz"'), findsOneWidget);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });
}
