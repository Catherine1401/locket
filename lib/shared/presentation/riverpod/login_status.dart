import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/injection.dart';

final authStateProvider = StreamProvider<Token?>((ref) async* {
  final auth = await ref.read(authRepositoryProvider.future);
  yield* auth.authStateChanges();
});