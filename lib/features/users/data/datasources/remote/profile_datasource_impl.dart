import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:locket/features/users/data/datasources/remote/profile_datasource.dart';
import 'package:locket/features/users/domain/entities/profile.dart';

final class ProfileDatasourceImpl implements ProfileDatasource {
  final Dio _dio;
  ProfileDatasourceImpl(this._dio);

  @override
  FutureOr<Profile?> getProfile() async {
    const path = '/users/me';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final profile = Profile(
          id: response.data['id'],
          email: response.data['email'],
          displayName: response.data['displayName'],
          avatarUrl: response.data['avatarUrl'],
          birthday: response.data['birthday'],
        );
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint("Error from getProfile: $e");
      return null;
    }
  }

  @override
  Future<String?> updateAvatar(String filePath) async {
    const path = '/users/me/avatar';
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
    });
    final response = await _dio.put(path, data: formData);
    if (response.statusCode == 200) {
      return response.data['avatarUrl'] as String?;
    }
    throw Exception('updateAvatar failed: ${response.statusCode}');
  }

  @override
  Future<String?> updateBirthday(String birthday) async {
    const path = '/users/me/birthday';
    final response = await _dio.put(path, data: {'birthday': birthday});
    if (response.statusCode == 200) {
      return response.data['birthday'] as String?;
    }
    throw Exception('updateBirthday failed: \${response.statusCode}');
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      debugPrint("updateDisplayName: $displayName");
      const path = '/users/me/name';
      await _dio.put(path, data: {'displayName': displayName});
    } catch (e) {
      debugPrint("Error from updateDisplayName: $e");
    }
  }
  
}
