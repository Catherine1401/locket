import 'dart:async';

import 'package:locket/features/users/data/datasources/remote/profile_datasource.dart';
import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/domain/repositories/profile_repository.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;
  ProfileRepositoryImpl(this._datasource);

  @override
  FutureOr<Profile?> getProfile() async {
    return await _datasource.getProfile();
  }

  @override
  Future<String?> updateAvatar(String filePath) async {
    return await _datasource.updateAvatar(filePath);
  }

  @override
  Future<void> updateBirthday(String birthday) {
    // TODO: implement updateBirthday
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _datasource.updateDisplayName(displayName);
  }
}
