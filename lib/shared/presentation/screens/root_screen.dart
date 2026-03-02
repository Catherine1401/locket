import 'package:flutter/material.dart';
import 'package:locket/features/moments/presentation/screens/camera_screen.dart';
import 'package:locket/features/users/presentation/screens/profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // camera = page 0
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Khi đang ở profile (page 1), back button quay về camera (page 0)
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentPage = _pageController.page?.round() ?? 0;
        if (currentPage > 0) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          children: const [
            CameraScreen(),   // index 0 — default
            ProfileScreen(),  // index 1 — vuốt trái để tới
          ],
        ),
      ),
    );
  }
}
