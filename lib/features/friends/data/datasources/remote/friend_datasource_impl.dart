import 'package:dio/dio.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/entities/friend_request.dart';

final class FriendDatasourceImpl implements FriendDatasource {
  final Dio _dio;
  FriendDatasourceImpl(this._dio);

  @override
  Future<List<Friend>> getFriends() async {
    try {
      final response = await _dio.get('/friends');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('FriendDatasourceImpl.getFriends error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserByShareCode(String shareCode) async {
    try {
      final response = await _dio.get('/users/$shareCode');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('FriendDatasourceImpl.getUserByShareCode error: $e');
      return null;
    }
  }

  @override
  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      final response = await _dio.post(
        '/friend-requests',
        data: {'toUserId': toUserId},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('FriendDatasourceImpl.sendFriendRequest error: $e');
      return false;
    }
  }

  @override
  Future<List<FriendRequest>> getIncomingRequests() async {
    try {
      final response = await _dio.get('/friend-requests/incoming');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list.map((e) => FriendRequest.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('FriendDatasourceImpl.getIncomingRequests error: $e');
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getOutgoingRequests() async {
    try {
      final response = await _dio.get('/friend-requests/outgoing');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list.map((e) => FriendRequest.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('FriendDatasourceImpl.getOutgoingRequests error: $e');
      return [];
    }
  }

  @override
  Future<bool> respondFriendRequest(String requestId, String status) async {
    try {
      final response = await _dio.put(
        '/friend-requests/$requestId',
        data: {'message': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('FriendDatasourceImpl.respondFriendRequest error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteFriendRequest(String requestId) async {
    try {
      final response = await _dio.delete('/friend-requests/$requestId');
      return response.statusCode == 200;
    } catch (e) {
      print('FriendDatasourceImpl.deleteFriendRequest error: $e');
      return false;
    }
  }

  @override
  Future<bool> removeFriend(String friendId) async {
    try {
      final response = await _dio.delete('/friends/$friendId');
      return response.statusCode == 200;
    } catch (e) {
      print('FriendDatasourceImpl.removeFriend error: $e');
      return false;
    }
  }
}
