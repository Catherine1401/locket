import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource_impl.dart';
import 'package:locket/features/users/data/datasources/remote/profile_datasource.dart';
import 'package:locket/features/users/data/datasources/remote/profile_datasource_impl.dart';
import 'package:locket/features/users/data/repositories/auth_repository_impl.dart';
import 'package:locket/features/users/data/repositories/profile_repository_impl.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';
import 'package:locket/features/users/domain/repositories/profile_repository.dart';
import 'package:locket/features/users/domain/usecases/get_authstate_usecase.dart';
import 'package:locket/features/users/domain/usecases/get_profile_usecase.dart';
import 'package:locket/features/users/domain/usecases/get_token_usecase.dart';
import 'package:locket/features/users/domain/usecases/login_usecase.dart';
import 'package:locket/features/users/domain/usecases/signout_usecase.dart';
import 'package:locket/features/users/domain/usecases/update_displayname_usecase.dart';

// authDatasourceProvider
final authDatasoueceProvider = FutureProvider<AuthDatasource>((ref) async {
  final token = await ref.watch(tokenProvider.future);
  final dio = await ref.read(dioProvider.future);
  return AuthDataSourceImpl(
    ref.read(googleProvider),
    ref.read(storageProvider),
    token,
    dio,
  );
});

// authRepositoryProvider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final dio = await ref.read(dioProvider.future);
  final authDatasource = await ref.read(authDatasoueceProvider.future);
  return AuthRepositoryImpl(dio, authDatasource);
});

// login use case
final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final authRepository = await ref.read(authRepositoryProvider.future);
  return LoginUseCase(authRepository);
});

// sign out use case
final signoutUseCaseProvider = FutureProvider<SignoutUseCase>((ref) async {
  final authRepository = await ref.read(authRepositoryProvider.future);
  return SignoutUseCase(authRepository);
});

// profileDatasourceProvider
final profileDatasourceProvider = FutureProvider<ProfileDatasource>((
  ref,
) async {
  final dio = await ref.read(dioProvider.future);
  return ProfileDatasourceImpl(dio);
});

// profileRepositoryProvider
final profileRepositoryProvider = FutureProvider<ProfileRepository>((
  ref,
) async {
  final profileDatasource = await ref.read(profileDatasourceProvider.future);
  return ProfileRepositoryImpl(profileDatasource);
});

// get profile use case
final getProfileUseCaseProvider = FutureProvider<GetProfileUseCase>((
  ref,
) async {
  final profileRepository = await ref.read(profileRepositoryProvider.future);
  return GetProfileUseCase(profileRepository);
});

// update display name use case
final updateDisplayNameUseCaseProvider =
    FutureProvider<UpdateDisplaynameUsecase>((ref) async {
      final profileRepository = await ref.read(
        profileRepositoryProvider.future,
      );
      return UpdateDisplaynameUsecase(profileRepository);
    });

// get token use case
final getTokenUseCaseProvider = FutureProvider<GetTokenUseCase>((ref) async {
  final authRepository = await ref.read(authRepositoryProvider.future);
  return GetTokenUseCase(authRepository);
});

// get auth state use case
final getAuthStateUseCaseProvider = FutureProvider<GetAuthStateUsecase>((
  ref,
) async {
  final authRepository = await ref.read(authRepositoryProvider.future);
  return GetAuthStateUsecase(authRepository);
});
