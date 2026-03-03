import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';

// Đây là state object giữ toàn bộ trạng thái của Feed/Grid
class MomentFeedState {
  final List<Moment> moments;
  final bool isLoading;
  final bool isFetchingMore;
  final String? nextCursor;
  final String? prevCursor;
  final String? error;

  const MomentFeedState({
    this.moments = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.nextCursor,
    this.prevCursor,
    this.error,
  });

  MomentFeedState copyWith({
    List<Moment>? moments,
    bool? isLoading,
    bool? isFetchingMore,
    String? nextCursor,
    String? prevCursor,
    String? error,
  }) {
    return MomentFeedState(
      moments: moments ?? this.moments,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      nextCursor: nextCursor ?? this.nextCursor,
      prevCursor: prevCursor ?? this.prevCursor,
      error: error,
    );
  }
}

class MomentFeedNotifier extends StateNotifier<MomentFeedState> {
  // Thêm dependency UseCase hoặc Repository ở đây khi cần gọi API
  MomentFeedNotifier() : super(const MomentFeedState());

  // 1. Initial Load: Gọi api /moments/feed lần đầu
  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Call API get moments 
      // final result = await getFeedUseCase.call(limit: 20);
      
      state = state.copyWith(
        isLoading: false,
        moments: [], // data từ API
        nextCursor: 'mock_next_cursor',
        prevCursor: 'mock_prev_cursor',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 2. Load More (Cuộn xuống): Gọi api truyền nextCursor
  Future<void> loadMore() async {
    if (state.isFetchingMore || state.nextCursor == null) return;
    state = state.copyWith(isFetchingMore: true);

    try {
      // TODO: Call API get moments with nextCursor
      await Future.delayed(const Duration(milliseconds: 500));

      final List<Moment> newMoments = []; // data mới
      
      state = state.copyWith(
        isFetchingMore: false,
        moments: [...state.moments, ...newMoments],
        nextCursor: 'new_next_cursor', // update theo API
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

  // 3. Load Previous (Cuộn lên - ít dùng nếu feed bắt đầu từ mới nhất): Truyền prevCursor
  Future<void> loadPrevious() async {
    if (state.isFetchingMore || state.prevCursor == null) return;
    state = state.copyWith(isFetchingMore: true);

    try {
      // TODO: Call API get moments with prevCursor
      await Future.delayed(const Duration(milliseconds: 500));

      final List<Moment> oldMoments = []; // data cũ hơn
      
      state = state.copyWith(
        isFetchingMore: false,
        // Chú ý: prepend data vào trên cùng list
        moments: [...oldMoments, ...state.moments],
        prevCursor: 'new_prev_cursor', 
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

  // Tiện ích để thêm moment mới do chính user vừa post
  void appendNewMoment(Moment moment) {
    state = state.copyWith(
      moments: [moment, ...state.moments],
    );
  }
}

// Global Provider
final momentFeedProvider =
    StateNotifierProvider<MomentFeedNotifier, MomentFeedState>((ref) {
  return MomentFeedNotifier();
});
