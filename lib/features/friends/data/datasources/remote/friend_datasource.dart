import 'package:locket/features/friends/domain/entities/friend.dart';

abstract interface class FriendDatasource {
  Future<List<Friend>> getFriends();
}
