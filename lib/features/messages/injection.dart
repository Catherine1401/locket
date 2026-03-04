import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/messages/data/datasources/remote/message_datasource.dart';
import 'package:locket/features/messages/data/datasources/remote/message_datasource_impl.dart';
import 'package:locket/features/messages/data/repositories/message_repository_impl.dart';
import 'package:locket/features/messages/domain/repositories/message_repository.dart';
import 'package:locket/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:locket/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:locket/features/messages/domain/usecases/send_message_usecase.dart';

final messageDatasourceProvider =
    FutureProvider<MessageDatasource>((ref) async {
  final dio = await ref.read(dioProvider.future);
  return MessageDatasourceImpl(dio);
});

final messageRepositoryProvider =
    FutureProvider<MessageRepository>((ref) async {
  final datasource = await ref.read(messageDatasourceProvider.future);
  return MessageRepositoryImpl(datasource);
});

final getConversationsUseCaseProvider =
    FutureProvider<GetConversationsUseCase>((ref) async {
  final repo = await ref.read(messageRepositoryProvider.future);
  return GetConversationsUseCase(repo);
});

final getMessagesUseCaseProvider =
    FutureProvider<GetMessagesUseCase>((ref) async {
  final repo = await ref.read(messageRepositoryProvider.future);
  return GetMessagesUseCase(repo);
});

final sendMessageUseCaseProvider =
    FutureProvider<SendMessageUseCase>((ref) async {
  final repo = await ref.read(messageRepositoryProvider.future);
  return SendMessageUseCase(repo);
});
