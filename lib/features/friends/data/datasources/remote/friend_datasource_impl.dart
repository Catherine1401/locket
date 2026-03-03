import 'package:dio/dio.dart';
import 'package:locket/features/friends/data/datasources/remote/friend_datasource.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';

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
}
