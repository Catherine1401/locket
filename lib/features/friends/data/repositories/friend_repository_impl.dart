import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/entities/friend_request.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final class FriendRepositoryImpl implements FriendRepository {
  final FriendDatasource _datasource;
  FriendRepositoryImpl(this._datasource);

  @override
  Future<List<Friend>> getFriends() => _datasource.getFriends();

  @override
  Future<Map<String, dynamic>?> getUserByShareCode(String shareCode) =>
      _datasource.getUserByShareCode(shareCode);

  @override
  Future<bool> sendFriendRequest(String toUserId) =>
      _datasource.sendFriendRequest(toUserId);

  @override
  Future<List<FriendRequest>> getIncomingRequests() =>
      _datasource.getIncomingRequests();

  @override
  Future<List<FriendRequest>> getOutgoingRequests() =>
      _datasource.getOutgoingRequests();

  @override
  Future<bool> respondFriendRequest(String requestId, String status) =>
      _datasource.respondFriendRequest(requestId, status);

  @override
  Future<bool> deleteFriendRequest(String requestId) =>
      _datasource.deleteFriendRequest(requestId);

  @override
  Future<bool> removeFriend(String friendId) =>
      _datasource.removeFriend(friendId);
}
