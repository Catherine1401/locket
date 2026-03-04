import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/messages/presentation/screens/conversations_screen.dart';
import 'package:locket/features/moments/presentation/screens/camera_screen.dart';
import 'package:locket/features/users/presentation/screens/profile_screen.dart';

// Layout:
//  index 0 — ProfileScreen      (vuốt phải từ Camera)
//  index 1 — CameraScreen       (default)
//  index 2 — ConversationsScreen (vuốt trái từ Camera)

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(rootPageControllerProvider);

    // Kết nối Socket.IO với access token khi người dùng đã authenticated
    ref.listen(tokenProvider, (_, tokenAsync) {
      tokenAsync.whenData((token) {
        if (token.accessToken != null && token.accessToken!.isNotEmpty) {
          final socketService = ref.read(socketServiceProvider);
          if (!socketService.isConnected) {
            socketService.connect(host, token.accessToken!);
          }
        }
      });
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentPage = pageController.page?.round() ?? 1;
        if (currentPage != 1) {
          // Từ Profile hoặc Conversations → back về Camera
          pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: PageView(
          controller: pageController,
          physics: const BouncingScrollPhysics(),
          children: const [
            ProfileScreen(),       // index 0 — vuốt phải từ Camera
            CameraScreen(),        // index 1 — default
            ConversationsScreen(), // index 2 — vuốt trái từ Camera
          ],
        ),
      ),
    );
  }
}
