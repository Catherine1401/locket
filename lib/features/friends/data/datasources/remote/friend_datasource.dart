import 'package:locket/features/friends/domain/entities/friend.dart';

abstract interface class FriendDatasource {
  Future<List<Friend>> getFriends();
  Future<Map<String, dynamic>?> getUserByShareCode(String shareCode);
  Future<bool> sendFriendRequest(String toUserId);
  Future<List<dynamic>> getIncomingRequests();
  Future<List<dynamic>> getOutgoingRequests();
  Future<bool> respondFriendRequest(String requestId, String status);
  Future<bool> deleteFriendRequest(String requestId);
  Future<bool> removeFriend(String friendId);
}
