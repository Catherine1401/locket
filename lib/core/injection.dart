import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/core/network/token_queuedinterceptor.dart';
import 'package:locket/core/utils/auth_event_bus.dart';
import 'package:locket/features/users/presentation/riverpod/auth_state_provider.dart';
import 'package:locket/features/users/presentation/screens/login_screen.dart';
import 'package:locket/features/users/presentation/screens/profile_screen.dart';
import 'package:locket/shared/presentation/screens/root_screen.dart';

const host = String.fromEnvironment('HOST');

// storage provider
final storageProvider = Provider<FlutterSecureStorage>((_) {
  return FlutterSecureStorage(aOptions: AndroidOptions());
});

// token provider
final tokenProvider = FutureProvider<Token>((ref) async {
  final accessToken = await ref.read(storageProvider).read(key: 'accessToken');
  final refreshToken = await ref
      .read(storageProvider)
      .read(key: 'refreshToken');

  return Token(accessToken: accessToken, refreshToken: refreshToken);
});

// google provider
final googleProvider = Provider<GoogleSignIn>((_) => GoogleSignIn.instance);

// dio provider
final dioProvider = FutureProvider<Dio>((ref) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: host,
      connectTimeout: Duration(seconds: 5),
      sendTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );
  final token = await ref.watch(tokenProvider.future);
  dio.interceptors.add(
    TokenQueuedinterceptor(
      dio,
      token,
      ref.read(storageProvider),
      ref.read(authEventBusProvider),
    ),
  );
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  return dio;
});

// config router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
      final authState = await ref.watch(authStateProvider.future);
      if (!authState) {
        return '/login';
      }
      return null;
    },
  );
});

// auth event bus
final authEventBusProvider = Provider<AuthEventBus>((_) => AuthEventBus());
