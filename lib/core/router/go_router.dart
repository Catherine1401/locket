import 'package:go_router/go_router.dart';
import 'package:locket/features/users/presentation/screens/login_screen.dart';
import 'package:locket/shared/presentation/screens/root_screen.dart';

base class RouterCfig {
  static final routerConfig = GoRouter(
    initialLocation: '/login',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            RootScreen(navigationShell: navigationShell),
        branches: [
          // login
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
            ],
          ),

          // // profile
          // StatefulShellBranch(routes: [GoRoute(path: '/profile')]),
        ],
      ),
    ],
  );
}
