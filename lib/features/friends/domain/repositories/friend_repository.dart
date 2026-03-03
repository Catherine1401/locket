import 'package:locket/features/friends/domain/entities/friend.dart';

abstract interface class FriendRepository {
  Future<List<Friend>> getFriends();
}
