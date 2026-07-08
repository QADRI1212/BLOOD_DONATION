import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation/core/utils/pagination_notifier.dart';

/// A concrete implementation of PaginatedNotifier for testing.
class TestNotifier extends PaginatedNotifier<String> {
  final Future<List<String>> Function(int page, int pageSize) fetchFn;

  TestNotifier(this.fetchFn);

  @override
  Future<List<String>> fetchPage(int page, int pageSize) async {
    return fetchFn(page, pageSize);
  }
}

void main() {
  group('PaginatedState', () {
    test('creates with default values', () {
      const state = PaginatedState<String>();
      expect(state.items, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
      expect(state.currentPage, equals(0));
    });

    test('creates with custom values', () {
      const state = PaginatedState<String>(
        items: ['a', 'b'],
        isLoading: true,
        hasMore: false,
        currentPage: 2,
      );
      expect(state.items, equals(['a', 'b']));
      expect(state.isLoading, isTrue);
      expect(state.hasMore, isFalse);
      expect(state.currentPage, equals(2));
    });

    test('copyWith preserves unchanged fields', () {
      const state = PaginatedState<String>(items: ['a'], currentPage: 1);
      final copy = state.copyWith(isLoading: true);
      expect(copy.items, equals(['a']));
      expect(copy.isLoading, isTrue);
      expect(copy.currentPage, equals(1));
      expect(copy.hasMore, isTrue);
    });

    test('copyWith updates provided fields with typed list', () {
      const state = PaginatedState<String>();
      final items = <String>['x', 'y', 'z'];
      final copy = state.copyWith(items: items, hasMore: false, currentPage: 3);
      expect(copy.items, equals(['x', 'y', 'z']));
      expect(copy.hasMore, isFalse);
      expect(copy.currentPage, equals(3));
    });

    test('copyWith correctly types generic list parameter', () {
      // This tests the bug we fixed where List<Never> was inferred
      const state = PaginatedState<String>();
      final typedList = <String>['hello'];
      // Should not throw type error
      expect(() => state.copyWith(items: typedList), returnsNormally);
      final copy = state.copyWith(items: typedList);
      expect(copy.items, equals(['hello']));
    });
  });

  group('PaginatedNotifier', () {
    late TestNotifier notifier;

    tearDown(() {
      notifier.dispose();
    });

    test('initial state has default values', () {
      notifier = TestNotifier((page, size) async => []);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.hasMore, isTrue);
      expect(notifier.state.currentPage, equals(0));
    });

    test('loadFirstPage sets items from fetchPage', () async {
      notifier = TestNotifier((page, size) async => ['a', 'b', 'c']);
      await notifier.loadFirstPage();

      expect(notifier.state.items, equals(['a', 'b', 'c']));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.currentPage, equals(0));
    });

    test('loadFirstPage sets hasMore when items equal pageSize', () async {
      // pageSize is 20, so returning 20 items means there are more
      notifier = TestNotifier(
        (page, size) async => List.generate(size, (i) => 'item $i'),
      );
      await notifier.loadFirstPage();

      expect(notifier.state.items.length, equals(20));
      expect(notifier.state.hasMore, isTrue);
    });

    test('loadFirstPage sets hasMore false when items less than pageSize', () async {
      notifier = TestNotifier((page, size) async => ['only one']);
      await notifier.loadFirstPage();

      expect(notifier.state.hasMore, isFalse);
    });

    test('loadFirstPage sets error when fetchPage throws', () async {
      notifier = TestNotifier((page, size) async {
        throw Exception('Network error');
      });
      await notifier.loadFirstPage();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('Network error'));
      expect(notifier.state.items, isEmpty);
    });

    test('loadNextPage appends items and increments page', () async {
      notifier = TestNotifier(
        (page, size) async => List.generate(
          size,
          (i) => 'page${page}_item$i',
        ),
      );
      await notifier.loadFirstPage();
      expect(notifier.state.items.length, equals(20));
      expect(notifier.state.hasMore, isTrue);

      await notifier.loadNextPage();
      expect(notifier.state.items.length, equals(40));
      expect(notifier.state.currentPage, equals(1));
    });

    test('loadNextPage does nothing when hasMore is false', () async {
      notifier = TestNotifier((page, size) async => ['only one']);
      await notifier.loadFirstPage(); // hasMore becomes false

      final stateBefore = notifier.state;
      await notifier.loadNextPage();

      // State should remain unchanged
      expect(notifier.state.items, equals(stateBefore.items));
      expect(notifier.state.currentPage, equals(stateBefore.currentPage));
    });

    test('loadNextPage sets error when fetchPage throws on second page', () async {
      int callCount = 0;
      notifier = TestNotifier((page, size) async {
        callCount++;
        if (callCount == 1) {
          // First call (page 0) succeeds
          return List.generate(20, (i) => 'item$i');
        }
        // Second call (page 1) fails
        throw Exception('Failed to load page 1');
      });

      await notifier.loadFirstPage();
      expect(notifier.state.items.length, equals(20));
      expect(notifier.state.error, isNull);

      await notifier.loadNextPage();

      // Should have set error and cleared loading state
      expect(notifier.state.isLoadingMore, isFalse);
      expect(notifier.state.error, contains('Failed to load page 1'));
      // Items should still contain the first page data
      expect(notifier.state.items.length, equals(20));
      // Page should not have advanced
      expect(notifier.state.currentPage, equals(0));
    });

    test('loadNextPage does nothing when already loading more (isLoadingMore guard)', () async {
      final completer = Completer<List<String>>();

      notifier = TestNotifier((page, size) async {
        if (page == 0) {
          return List.generate(20, (i) => 'item$i');
        }
        // Page 1+ waits on the completer so we can test concurrent calls
        return completer.future;
      });

      await notifier.loadFirstPage();
      expect(notifier.state.items.length, equals(20));
      expect(notifier.state.hasMore, isTrue);

      // Start first loadNextPage (will set isLoadingMore=true and wait)
      final firstCall = notifier.loadNextPage();
      // isLoadingMore should now be true
      expect(notifier.state.isLoadingMore, isTrue);

      // Second call should return immediately due to isLoadingMore guard
      await notifier.loadNextPage();
      // State should still show loading because the first call hasn't completed
      expect(notifier.state.isLoadingMore, isTrue);
      expect(notifier.state.currentPage, equals(0));

      // Now complete the first call
      completer.complete(List.generate(5, (i) => 'page1_item$i'));
      await firstCall;

      // State should now reflect page 1 data
      expect(notifier.state.isLoadingMore, isFalse);
      expect(notifier.state.items.length, equals(25));
      expect(notifier.state.currentPage, equals(1));
    });

    test('refresh resets state and reloads', () async {
      int callCount = 0;
      notifier = TestNotifier((page, size) async {
        callCount++;
        return ['data_$callCount'];
      });

      await notifier.loadFirstPage();
      expect(notifier.state.items, equals(['data_1']));

      await notifier.refresh();
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.items, equals(['data_2']));
    });

    test('refresh creates PaginatedState with correct generic type', () async {
      // This tests the fix: state = PaginatedState<T>(isLoading: true)
      notifier = TestNotifier((page, size) async => <String>[]);
      await notifier.refresh();

      // After refresh -> loadFirstPage completes, items should be empty list
      expect(notifier.state.items, isA<List<String>>());
      expect(notifier.state.items, isEmpty);
    });
  });
}
