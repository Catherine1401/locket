import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/presentation/screens/login_screen.dart';
import 'package:locket/features/users/presentation/screens/profile_screen.dart';
import 'package:locket/shared/presentation/riverpod/login_status.dart';
import 'package:locket/shared/presentation/screens/root_screen.dart';

const host = String.fromEnvironment('HOST');

final storageProvider = Provider<FlutterSecureStorage>((_) {
  return FlutterSecureStorage(aOptions: AndroidOptions());
});

final tokenProvider = FutureProvider<Token>((ref) async {
  final accessToken = await ref.read(storageProvider).read(key: 'accessToken');
  final refreshToken = await ref
      .read(storageProvider)
      .read(key: 'refreshToken');

  return Token(accessToken: accessToken, refreshToken: refreshToken);
});

final googleProvider = Provider<GoogleSignIn>((_) => GoogleSignIn.instance);
final dioProvider = Provider<Dio>((_) {
  final dio = Dio(BaseOptions(baseUrl: host));
  return dio;
});

// config routre
final routerProvider = FutureProvider<GoRouter>((ref) async {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) {
          return RootScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (_, _) async {
      print("redirect");
      final loginStatus = await ref.watch(loginStatusProvider.future);
      print("loginStatus: $loginStatus");
      if (!loginStatus) return '/login';
      return null;
    },
  );
  return router;
});
