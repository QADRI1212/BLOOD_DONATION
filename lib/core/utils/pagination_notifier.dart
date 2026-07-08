import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logger_service.dart';

/// State holder for a paginated list.
class PaginatedState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return PaginatedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// A reusable notifier for paginated lists with infinite scroll.
///
/// Usage:
/// 1. Create a subclass that implements [fetchPage].
/// 2. Call [loadFirstPage()] to load initial data.
/// 3. Call [loadNextPage()] when user scrolls near bottom.
/// 4. Call [refresh()] to reset and reload.
abstract class PaginatedNotifier<T> extends StateNotifier<PaginatedState<T>> {
  static const int defaultPageSize = 20;
  final LoggerService _logger = LoggerService();

  /// Override this to fetch one page of data.
  /// Return an empty list when there are no more items.
  Future<List<T>> fetchPage(int page, int pageSize);

  PaginatedNotifier() : super(PaginatedState<T>());

  /// Load the first page (page 0).
  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, error: null, currentPage: 0);

    try {
      final items = await fetchPage(0, defaultPageSize);
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length >= defaultPageSize,
        currentPage: 0,
        error: null,
      );
    } catch (e, stack) {
      _logger.error('Failed to load first page', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load the next page (appends to existing items).
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final items = await fetchPage(nextPage, defaultPageSize);
      state = state.copyWith(
        items: [...state.items, ...items],
        isLoadingMore: false,
        hasMore: items.length >= defaultPageSize,
        currentPage: nextPage,
        error: null,
      );
    } catch (e, stack) {
      _logger.error('Failed to load page ${state.currentPage + 1}', error: e, stackTrace: stack);
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Reset and reload from page 0.
  Future<void> refresh() async {
    state = PaginatedState<T>(isLoading: true);
    await loadFirstPage();
  }
}
