import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:locket/core/injection.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/injection.dart';
import 'package:locket/features/moments/presentation/screens/feed_screen.dart';
import 'package:locket/features/moments/presentation/screens/moment_preview_screen.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';

class CameraScreen extends HookConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameras = useState<List<CameraDescription>>([]);
    final controller = useState<CameraController?>(null);
    final isInitialized = useState(false);
    final isFlashOn = useState(false);
    final isFrontCamera = useState(false);

    useEffect(() {
      _initCameras(cameras, controller, isInitialized);
      return () => controller.value?.dispose();
    }, []);

    useEffect(() {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      return () =>
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }, []);

    void openFeed() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FeedScreen()),
    );

    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      body: GestureDetector(
        // Vuốt lên → FeedScreen
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -300) openFeed();
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header (avatar, bạn bè, chat) ──────────────────────
              _TopBar(
                friendCount: ref.watch(friendsListProvider).value?.length ?? 0,
                avatarUrl: ref.watch(profileProvider).value?.avatarUrl,
                onAvatarTap: () => ref.read(rootPageControllerProvider).animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                onChatTap: () => ref.read(rootPageControllerProvider).animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),

              // Khối camera + controls được canh giữa theo chiều dọc
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),

                    // ── Viewfinder 1:1 ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _Viewfinder(
                          controller: controller.value,
                          isInitialized: isInitialized.value,
                          isFlashOn: isFlashOn.value,
                          onFlashToggle: () async {
                            isFlashOn.value = !isFlashOn.value;
                            await controller.value?.setFlashMode(
                              isFlashOn.value
                                  ? FlashMode.torch
                                  : FlashMode.off,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Controls ──────────────────────────────────────
                    _ControlsBar(
                      onShutter: () async {
                        if (controller.value == null || !isInitialized.value) {
                          return;
                        }
                        try {
                          final image = await controller.value!.takePicture();
                          String finalPath = image.path;

                          // Lật ảnh nếu đang dùng camera trước
                          if (isFrontCamera.value) {
                            final bytes = await File(image.path).readAsBytes();
                            final decoded = img.decodeImage(bytes);
                            if (decoded != null) {
                              final flipped = img.flipHorizontal(decoded);
                              final flippedBytes = img.encodeJpg(flipped, quality: 90);
                              await File(image.path).writeAsBytes(flippedBytes);
                            }
                          }

                          if (context.mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MomentPreviewScreen(
                                  imagePath: finalPath,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Shutter error: $e');
                        }
                      },
                      onFlip: () async {
                        if (cameras.value.length < 2) return;
                        isFrontCamera.value = !isFrontCamera.value;
                        await _switchCamera(
                          cameras.value,
                          controller,
                          isInitialized,
                          isFrontCamera.value,
                        );
                      },
                      onGrid: () {},
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              // ── Footer luôn sát đáy ────────────────────────────────
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initCameras(
    ValueNotifier<List<CameraDescription>> cameras,
    ValueNotifier<CameraController?> controller,
    ValueNotifier<bool> isInitialized,
  ) async {
    try {
      final list = await availableCameras();
      cameras.value = list;
      if (list.isEmpty) return;
      final ctrl = CameraController(list.first, ResolutionPreset.high);
      await ctrl.initialize();
      controller.value = ctrl;
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _switchCamera(
    List<CameraDescription> list,
    ValueNotifier<CameraController?> controller,
    ValueNotifier<bool> isInitialized,
    bool front,
  ) async {
    try {
      isInitialized.value = false;
      await controller.value?.dispose();
      final cam = front
          ? list.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => list.first)
          : list.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => list.first);
      final ctrl = CameraController(cam, ResolutionPreset.high);
      await ctrl.initialize();
      controller.value = ctrl;
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Flip error: $e');
    }
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final int friendCount;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onChatTap;
  const _TopBar({required this.friendCount, this.avatarUrl, this.onAvatarTap, this.onChatTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AvatarBtn(
              avatarUrl: avatarUrl,
              onTap: onAvatarTap,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Center(
                child: _FriendPill(friendCount: friendCount),
              ),
            ),

            const SizedBox(width: 16),

            _RoundedSquareBtn(
              onTap: onChatTap,
              child: const Icon(Icons.chat_bubble_rounded,
                  color: MyColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}



// Avatar button — show real profile picture or fallback icon
class _AvatarBtn extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback? onTap;
  const _AvatarBtn({this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: MyColors.cameraHeaderBtnBg,
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _PersonIcon(),
                  errorWidget: (_, __, ___) => const _PersonIcon(),
                )
              : const _PersonIcon(),
        ),
      ),
    );
  }
}

class _PersonIcon extends StatelessWidget {
  const _PersonIcon();
  @override
  Widget build(BuildContext context) => const Icon(
    Icons.person_outline,
    color: MyColors.white,
    size: 20,
  );
}



class _RoundedSquareBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _RoundedSquareBtn({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: MyColors.cameraHeaderBtnBg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _FriendPill extends StatelessWidget {
  final int friendCount;
  const _FriendPill({required this.friendCount});

  @override
  Widget build(BuildContext context) {
    final label = friendCount == 0
        ? 'Thêm bạn bè'
        : '$friendCount bạn bè';
    return GestureDetector(
      onTap: () {
        context.push('/friends');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: MyColors.cameraPillBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_outlined, color: MyColors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: MyColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Viewfinder ───────────────────────────────────────────────────────────────

class _Viewfinder extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;

  const _Viewfinder({
    this.controller,
    required this.isInitialized,
    required this.isFlashOn,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Vuông 1:1, bo tròn 4 góc, icon flash & zoom overlay như ảnh gốc
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          isInitialized && controller != null
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.previewSize?.height ?? 720,
                    height: controller!.value.previewSize?.width ?? 1280,
                    child: CameraPreview(controller!),
                  ),
                )
              : const ColoredBox(
                  color: MyColors.cameraViewfinderBg,
                  child: Center(
                    child: Icon(Icons.camera_alt_outlined,
                        color: MyColors.white, size: 48),
                  ),
                ),

          // Flash icon góc trên trái
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onFlashToggle,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt,
                  size: 18,
                  color: isFlashOn
                      ? MyColors.cameraFlashActive
                      : MyColors.white,
                ),
              ),
            ),
          ),

          // Zoom badge "1x" góc trên phải
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '1x',
                style: TextStyle(
                  color: MyColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Controls Bar ─────────────────────────────────────────────────────────────

class _ControlsBar extends StatelessWidget {
  final VoidCallback onShutter;
  final VoidCallback onFlip;
  final VoidCallback? onGrid;

  const _ControlsBar({
    required this.onShutter,
    required this.onFlip,
    this.onGrid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: MyColors.cameraBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Grid / media icon (trái)
          GestureDetector(
            onTap: onGrid,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: MyColors.white,
                size: 30,
              ),
            ),
          ),

          const SizedBox(width: 32),

          // Shutter — 3 layers: vàng → khoảng đen → lõi trắng
          GestureDetector(
            onTap: onShutter,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: MyColors.bgButtonLogin,
                  width: 4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.black,
                  ),
                  child: Center(
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 32),

          // Flip — icon xoay camera
          GestureDetector(
            onTap: onFlip,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.flip_camera_ios,
                size: 30,
                color: MyColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MyColors.cameraBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: MyColors.bgButtonLogin,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '9',
                    style: TextStyle(
                      color: MyColors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lịch sử',
                  style: TextStyle(
                    color: MyColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Icon(Icons.expand_more, color: MyColors.white, size: 20),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
