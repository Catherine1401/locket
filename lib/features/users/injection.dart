import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource_impl.dart';
import 'package:locket/features/users/data/repositories/auth_repository_impl.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';
import 'package:locket/features/users/domain/usecases/login_usecase.dart';

final authDatasoueceProvider = FutureProvider<AuthDatasource>((ref) async {
  final token = await ref.watch(tokenProvider.future);
  return AuthDataSourceImpl(
    ref.read(googleProvider),
    ref.read(storageProvider),
    token,
  );
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final dio = await ref.read(dioProvider.future);
  final authDatasource = await ref.read(authDatasoueceProvider.future);
  return AuthRepositoryImpl(dio, authDatasource);
});

final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final authRepository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(authRepository);
});
