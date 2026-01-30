import 'dart:async';

import 'package:locket/features/users/data/datasources/remote/profile_datasource.dart';
import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/domain/repositories/profile_repository.dart';

base class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;
  ProfileRepositoryImpl(this._datasource);

  @override
  FutureOr<Profile?> getProfile() async {
    return await _datasource.getProfile();
  }
  
}
