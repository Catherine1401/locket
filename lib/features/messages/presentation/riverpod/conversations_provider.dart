import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/injection.dart';

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

final class ConversationsNotifier
    extends AsyncNotifier<List<Conversation>> {
  @override
  FutureOr<List<Conversation>> build() async {
    final useCase = await ref.read(getConversationsUseCaseProvider.future);
    return useCase.call();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getConversationsUseCaseProvider.future);
      return useCase.call();
    });
  }
}
