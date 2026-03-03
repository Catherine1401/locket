import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource_impl.dart';
import 'package:locket/features/friends/data/repositories/friend_repository_impl.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';
import 'package:locket/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:locket/features/friends/domain/usecases/get_user_by_sharecode_usecase.dart';
import 'package:locket/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:locket/features/friends/domain/usecases/respond_friend_request_usecase.dart';
import 'package:locket/features/friends/domain/usecases/get_incoming_requests_usecase.dart';
import 'package:locket/features/friends/domain/usecases/get_outgoing_requests_usecase.dart';
import 'package:locket/features/friends/domain/usecases/delete_friend_request_usecase.dart';
import 'package:locket/features/friends/domain/usecases/remove_friend_usecase.dart';

final friendDatasourceProvider = FutureProvider<FriendDatasource>((ref) async {
  final dio = await ref.read(dioProvider.future);
  return FriendDatasourceImpl(dio);
});

final friendRepositoryProvider = FutureProvider<FriendRepository>((ref) async {
  final datasource = await ref.read(friendDatasourceProvider.future);
  return FriendRepositoryImpl(datasource);
});

final getFriendsUseCaseProvider =
    FutureProvider<GetFriendsUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return GetFriendsUseCase(repo);
});

final getUserByShareCodeUseCaseProvider =
    FutureProvider<GetUserByShareCodeUsecase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return GetUserByShareCodeUsecase(repo);
});

final sendFriendRequestUseCaseProvider =
    FutureProvider<SendFriendRequestUsecase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return SendFriendRequestUsecase(repo);
});

final respondFriendRequestUseCaseProvider =
    FutureProvider<RespondFriendRequestUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return RespondFriendRequestUseCase(repo);
});

final getIncomingRequestsUseCaseProvider =
    FutureProvider<GetIncomingRequestsUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return GetIncomingRequestsUseCase(repo);
});

final getOutgoingRequestsUseCaseProvider =
    FutureProvider<GetOutgoingRequestsUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return GetOutgoingRequestsUseCase(repo);
});

final deleteFriendRequestUseCaseProvider =
    FutureProvider<DeleteFriendRequestUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return DeleteFriendRequestUseCase(repo);
});

final removeFriendUseCaseProvider =
    FutureProvider<RemoveFriendUseCase>((ref) async {
  final repo = await ref.read(friendRepositoryProvider.future);
  return RemoveFriendUseCase(repo);
});
