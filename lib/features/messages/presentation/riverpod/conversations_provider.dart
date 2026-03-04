import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/injection.dart';

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

final class ConversationsNotifier
    extends AsyncNotifier<List<Conversation>> {
  StreamSubscription<dynamic>? _socketSub;

  @override
  FutureOr<List<Conversation>> build() async {
    final useCase = await ref.read(getConversationsUseCaseProvider.future);
    final conversations = await useCase.call();

    // Bắt đầu lắng nghe socket ngay khi provider được khởi tạo
    _subscribeToSocket();

    // Huỷ subscription khi provider bị dispose
    ref.onDispose(() {
      _socketSub?.cancel();
    });

    return conversations;
  }

  void _subscribeToSocket() {
    _socketSub?.cancel();

    final socketService = ref.read(socketServiceProvider);

    _socketSub = socketService.onNewMessage().listen((newMessage) {
      final current = state.value;
      if (current == null) return;

      // Tìm conversation tương ứng với tin nhắn mới
      final idx = current.indexWhere((c) => c.id == newMessage.conversationId);
      if (idx == -1) return;

      // Cập nhật lastMessage và lastMessageAt
      final updated = current[idx].copyWith(
        lastMessage: newMessage.content,
        lastMessageAt: newMessage.createdAt,
      );

      // Đưa conversation đó lên đầu danh sách (mới nhất ở trên cùng)
      final newList = [
        updated,
        ...current.where((c) => c.id != newMessage.conversationId),
      ];

      state = AsyncValue.data(newList);
    });
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getConversationsUseCaseProvider.future);
      return useCase.call();
    });
    // Re-subscribe sau khi reload
    _subscribeToSocket();
  }
}
