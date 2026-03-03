import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource_impl.dart';
import 'package:locket/features/friends/data/repositories/friend_repository_impl.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';
import 'package:locket/features/friends/domain/usecases/get_friends_usecase.dart';

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
