import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/messages/domain/entities/message.dart';
import 'package:locket/features/messages/injection.dart';

// ── State ───────────────────────────────────────────────────────────────────

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? nextCursor;
  final bool hasMore;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextCursor,
    this.hasMore = true,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextCursor,
    bool? hasMore,
    String? error,
    bool clearError = false,
    bool clearNextCursor = false,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<ChatState> {
  StreamSubscription<Message>? _socketSub;

  @override
  ChatState build() => const ChatState();

  Future<void> loadInitial(String conversationId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final useCase = await ref.read(getMessagesUseCaseProvider.future);
      final result = await useCase.call(conversationId);
      state = ChatState(
        messages: result.messages,
        isLoading: false,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
      );

      // ── Kết nối Socket.IO và lắng nghe tin nhắn mới ──────────────────
      _joinSocketRoom(conversationId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Join socket room và subscribe vào stream new_message
  void _joinSocketRoom(String conversationId) {
    _socketSub?.cancel();

    final socketService = ref.read(socketServiceProvider);
    socketService.joinConversation(conversationId);

    _socketSub = socketService.onNewMessage().listen((newMessage) {
      // Tránh duplicate nếu chính người dùng này đã append message trong sendMessage()
      final isDuplicate = state.messages.any((m) => m.id == newMessage.id);
      if (!isDuplicate) {
        state = state.copyWith(messages: [...state.messages, newMessage]);
      }
    });
  }

  /// Huỷ socket subscription khi rời khỏi màn hình
  void leaveRoom(String conversationId) {
    _socketSub?.cancel();
    _socketSub = null;
    ref.read(socketServiceProvider).leaveConversation(conversationId);
  }

  Future<void> loadMore(String conversationId) async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final useCase = await ref.read(getMessagesUseCaseProvider.future);
      final result = await useCase.call(
        conversationId,
        nextCursor: state.nextCursor,
      );
      state = state.copyWith(
        messages: [...result.messages, ...state.messages],
        isLoadingMore: false,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String conversationId, String content, {String? replyToMomentId}) async {
    try {
      final useCase = await ref.read(sendMessageUseCaseProvider.future);
      final message = await useCase.call(conversationId, content, replyToMomentId: replyToMomentId);
      // Append message của người gửi ngay lập tức (optimistic update)
      // Socket event sẽ được lọc duplicate bằng message.id
      state = state.copyWith(messages: [...state.messages, message]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final chatProvider =
    NotifierProvider.autoDispose<ChatNotifier, ChatState>(ChatNotifier.new);
