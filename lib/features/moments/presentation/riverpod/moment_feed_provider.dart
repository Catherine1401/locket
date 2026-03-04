import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/injection.dart';

// ── Feed State ────────────────────────────────────────────────────────────────

class MomentFeedState {
  final List<Moment> moments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool nextEnd;
  final bool prevEnd;
  final String? nextCursor;
  final String? prevCursor;
  final String? filterUserId;
  final String? error;

  const MomentFeedState({
    this.moments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextEnd = true,
    this.prevEnd = true,
    this.nextCursor,
    this.prevCursor,
    this.filterUserId,
    this.error,
  });

  MomentFeedState copyWith({
    List<Moment>? moments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? nextEnd,
    bool? prevEnd,
    String? nextCursor,
    String? prevCursor,
    String? filterUserId,
    String? error,
    bool clearFilter = false,
    bool clearError = false,
    bool clearNextCursor = false,
  }) =>
      MomentFeedState(
        moments: moments ?? this.moments,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        nextEnd: nextEnd ?? this.nextEnd,
        prevEnd: prevEnd ?? this.prevEnd,
        nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
        prevCursor: prevCursor ?? this.prevCursor,
        filterUserId: clearFilter ? null : filterUserId ?? this.filterUserId,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Feed Notifier ─────────────────────────────────────────────────────────────

class MomentFeedNotifier extends Notifier<MomentFeedState> {
  @override
  MomentFeedState build() {
    Future.microtask(loadInitial);
    return const MomentFeedState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final useCase = await ref.read(getFeedUseCaseProvider.future);
      final page = await useCase.call(filterUserId: state.filterUserId);
      state = MomentFeedState(
        moments: page.moments,
        isLoading: false,
        nextEnd: page.nextEnd,
        prevEnd: page.prevEnd,
        nextCursor: page.nextCursor,
        prevCursor: page.prevCursor,
        filterUserId: state.filterUserId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.nextEnd || state.nextCursor == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final useCase = await ref.read(getFeedUseCaseProvider.future);
      final page = await useCase.call(
        nextCursor: state.nextCursor,
        filterUserId: state.filterUserId,
      );
      state = state.copyWith(
        moments: [...state.moments, ...page.moments],
        isLoadingMore: false,
        nextEnd: page.nextEnd,
        nextCursor: page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setFilter(String? userId) async {
    state = MomentFeedState(isLoading: true, filterUserId: userId);
    await loadInitial();
  }

  void prepend(Moment moment) {
    state = state.copyWith(moments: [moment, ...state.moments]);
  }
}

final momentFeedProvider =
    NotifierProvider<MomentFeedNotifier, MomentFeedState>(
  MomentFeedNotifier.new,
);

// ── Grid State ────────────────────────────────────────────────────────────────

class GridState {
  final List<GridMoment> moments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool nextEnd;
  final String? nextCursor;
  final String? filterUserId;

  const GridState({
    this.moments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextEnd = true,
    this.nextCursor,
    this.filterUserId,
  });

  GridState copyWith({
    List<GridMoment>? moments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? nextEnd,
    String? nextCursor,
    String? filterUserId,
    bool clearNextCursor = false,
  }) =>
      GridState(
        moments: moments ?? this.moments,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        nextEnd: nextEnd ?? this.nextEnd,
        nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
        filterUserId: filterUserId ?? this.filterUserId,
      );
}

// ── Grid Notifier ─────────────────────────────────────────────────────────────

class GridNotifier extends Notifier<GridState> {
  @override
  GridState build() {
    Future.microtask(loadInitial);
    return const GridState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final useCase = await ref.read(getGridUseCaseProvider.future);
      final page = await useCase.call(filterUserId: state.filterUserId);
      state = GridState(
        moments: page.moments,
        isLoading: false,
        nextEnd: page.nextEnd,
        nextCursor: page.nextCursor,
        filterUserId: state.filterUserId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.nextEnd || state.nextCursor == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final useCase = await ref.read(getGridUseCaseProvider.future);
      final page = await useCase.call(
        nextCursor: state.nextCursor,
        filterUserId: state.filterUserId,
      );
      state = state.copyWith(
        moments: [...state.moments, ...page.moments],
        isLoadingMore: false,
        nextEnd: page.nextEnd,
        nextCursor: page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> setFilter(String? userId) async {
    state = GridState(isLoading: true, filterUserId: userId);
    await loadInitial();
  }
}

final gridProvider = NotifierProvider<GridNotifier, GridState>(
  GridNotifier.new,
);
