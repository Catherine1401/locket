import 'dart:async';

import 'package:dio/dio.dart';
import 'package:locket/features/users/data/datasources/remote/profile_datasource.dart';
import 'package:locket/features/users/domain/entities/profile.dart';

base class ProfileDatasourceImpl implements ProfileDatasource {
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
      print("Error from getProfile: $e");
      return null;
    }
  }
  
}
