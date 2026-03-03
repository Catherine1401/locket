import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final class FriendRepositoryImpl implements FriendRepository {
  final FriendDatasource _datasource;
  FriendRepositoryImpl(this._datasource);

  @override
  Future<List<Friend>> getFriends() => _datasource.getFriends();
}
