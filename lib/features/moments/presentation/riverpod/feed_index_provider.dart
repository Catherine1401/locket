import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider lưu lại vị trí ảnh đang được xem (currentIndex) 
/// Mục đích: Đồng bộ index giữa PageView (Feed) và GridView
class FeedIndexNotifier extends StateNotifier<int> {
  FeedIndexNotifier() : super(0);

  // Cập nhật index mỗi khi user vuốt PageView trên Feed
  // Hoặc cuộn ScrollController trên GridView
  void updateIndex(int newIndex) {
    if (newIndex != state) {
      state = newIndex;
    }
  }
}

final feedIndexProvider =
    StateNotifierProvider<FeedIndexNotifier, int>((ref) {
  return FeedIndexNotifier();
});
