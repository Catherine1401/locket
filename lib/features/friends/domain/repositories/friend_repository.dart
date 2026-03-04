import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/entities/friend_request.dart';

abstract interface class FriendRepository {
  Future<List<Friend>> getFriends();
  Future<Map<String, dynamic>?> getUserByShareCode(String shareCode);
  Future<bool> sendFriendRequest(String toUserId);
  Future<List<FriendRequest>> getIncomingRequests();
  Future<List<FriendRequest>> getOutgoingRequests();
  Future<bool> respondFriendRequest(String requestId, String status);
  Future<bool> deleteFriendRequest(String requestId);
  Future<bool> removeFriend(String friendId);
}
