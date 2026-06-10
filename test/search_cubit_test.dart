import 'package:bloc_test/bloc_test.dart';
import 'package:calclyo/src/features/search/recents_repository.dart';
import 'package:calclyo/src/features/search/search_cubit.dart';
import 'package:calclyo/src/features/search/search_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  RecentsRepository repo({int maxRecents = 5}) =>
      RecentsRepository(preferences: prefs, maxRecents: maxRecents);

  group('SearchCubit', () {
    blocTest<SearchCubit, SearchState>(
      'loadRecents emits loading then ready with empty recents on cold start',
      build: () => SearchCubit(recents: repo()),
      act: (c) => c.loadRecents(),
      expect: () => [
        isA<SearchState>().having(
          (s) => s.status,
          'status',
          SearchStatus.loading,
        ),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.ready)
            .having((s) => s.recentQueries, 'recentQueries', isEmpty),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'loadRecents reuses persisted list on warm start',
      setUp: () async {
        // Seed the store before the Cubit is built.
        await prefs.setStringList('search.recents.v1', const ['percent']);
      },
      build: () => SearchCubit(recents: repo()),
      act: (c) => c.loadRecents(),
      expect: () => [
        isA<SearchState>().having(
          (s) => s.status,
          'status',
          SearchStatus.loading,
        ),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.ready)
            .having((s) => s.recentQueries, 'recentQueries', ['percent']),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'updateQuery recomputes results live (no I/O)',
      build: () => SearchCubit(recents: repo()),
      seed: () =>
          const SearchState.initial().copyWith(status: SearchStatus.ready),
      act: (c) => c.updateQuery('tip'),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', 'tip')
            .having(
              (s) => s.results.expand((g) => g.calculators).map((c) => c.id),
              'result ids',
              contains('tip'),
            ),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'updateQuery with empty string clears results (recents UX)',
      build: () => SearchCubit(recents: repo()),
      seed: () => const SearchState(
        status: SearchStatus.ready,
        query: 'tip',
        recentQueries: [],
        results: [],
      ),
      act: (c) => c.updateQuery(''),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', '')
            .having((s) => s.results, 'results', isEmpty),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'commitQuery persists a fresh query as the most recent',
      build: () => SearchCubit(recents: repo()),
      seed: () => const SearchState(
        status: SearchStatus.ready,
        query: 'percent',
        recentQueries: [],
        results: [],
      ),
      act: (c) => c.commitQuery(),
      verify: (_) async {
        final stored = prefs.getStringList('search.recents.v1');
        expect(stored, ['percent']);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'commitQuery dedupes case-insensitively and keeps newest first',
      setUp: () async {
        // Seed the store so push() sees the prior recents and dedupes
        // against them.
        await prefs.setStringList('search.recents.v1', const [
          'percent',
          'bmi',
        ]);
      },
      build: () => SearchCubit(recents: repo(maxRecents: 3)),
      seed: () => const SearchState(
        status: SearchStatus.ready,
        query: 'TIP',
        recentQueries: ['percent', 'bmi'],
        results: [],
      ),
      act: (c) => c.commitQuery(),
      expect: () => [
        isA<SearchState>().having((s) => s.recentQueries, 'recentQueries', [
          'TIP',
          'percent',
          'bmi',
        ]),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'commitQuery with blank query is a no-op',
      build: () => SearchCubit(recents: repo()),
      seed: () =>
          const SearchState.initial().copyWith(status: SearchStatus.ready),
      act: (c) => c.commitQuery(),
      expect: () => <SearchState>[],
    );

    blocTest<SearchCubit, SearchState>(
      'removeRecent deletes the matching entry and persists',
      setUp: () async {
        // Seed the store so RecentsRepository reads the existing list.
        await prefs.setStringList('search.recents.v1', const ['a', 'b', 'c']);
      },
      build: () => SearchCubit(recents: repo()),
      seed: () => const SearchState(
        status: SearchStatus.ready,
        query: '',
        recentQueries: ['a', 'b', 'c'],
        results: [],
      ),
      act: (c) => c.removeRecent('b'),
      expect: () => [
        isA<SearchState>().having((s) => s.recentQueries, 'recentQueries', [
          'a',
          'c',
        ]),
      ],
      verify: (_) async {
        expect(prefs.getStringList('search.recents.v1'), ['a', 'c']);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'commitQuery caps the recents list at maxRecents',
      setUp: () async {
        // Seed the store so push() sees the existing entries and caps them.
        await prefs.setStringList('search.recents.v1', const ['old1', 'old2']);
      },
      build: () => SearchCubit(recents: repo(maxRecents: 2)),
      seed: () => const SearchState(
        status: SearchStatus.ready,
        query: 'new',
        recentQueries: ['old1', 'old2'],
        results: [],
      ),
      act: (c) => c.commitQuery(),
      expect: () => [
        isA<SearchState>().having((s) => s.recentQueries, 'recentQueries', [
          'new',
          'old1',
        ]),
      ],
    );
  });
}
