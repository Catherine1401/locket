import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/moments/data/datasources/remote/moment_datasource.dart';
import 'package:locket/features/moments/data/datasources/remote/moment_datasource_impl.dart';
import 'package:locket/features/moments/data/repositories/moment_repository_impl.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';
import 'package:locket/features/moments/domain/usecases/create_moment_usecase.dart';

final momentDatasourceProvider = FutureProvider<MomentDatasource>((ref) async {
  final dio = await ref.read(dioProvider.future);
  return MomentDatasourceImpl(dio);
});

final momentRepositoryProvider = FutureProvider<MomentRepository>((ref) async {
  final datasource = await ref.read(momentDatasourceProvider.future);
  return MomentRepositoryImpl(datasource);
});

final createMomentUseCaseProvider =
    FutureProvider<CreateMomentUseCase>((ref) async {
  final repo = await ref.read(momentRepositoryProvider.future);
  return CreateMomentUseCase(repo);
});
