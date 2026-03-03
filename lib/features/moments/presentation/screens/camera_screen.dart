import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/core/theme/colors.dart';
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

    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header (avatar, bạn bè, chat) ──────────────────────
            _TopBar(
              hasFriends: false,
              avatarUrl: ref.watch(profileProvider).value?.avatarUrl,
              onAvatarTap: () => ref.read(rootPageControllerProvider).animateToPage(
                0,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                        debugPrint('Photo: ${image.path}');
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

class _TopBar extends StatelessWidget {
  final bool hasFriends;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  const _TopBar({required this.hasFriends, this.avatarUrl, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar — hình thật từ profile
            _AvatarBtn(
              avatarUrl: avatarUrl,
              onTap: onAvatarTap,
            ),

            const SizedBox(width: 16),

            // Friend pill — expanded/centered
            Expanded(
              child: Center(child: _FriendPill(hasFriends: hasFriends)),
            ),

            const SizedBox(width: 16),

            // Chat — rounded square (border-radius 10px, NOT circle)
            _RoundedSquareBtn(
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

// Circle button (generic)
class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _CircleBtn({required this.child, this.onTap});

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
        child: Center(child: child),
      ),
    );
  }
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _FriendPill extends StatelessWidget {
  final bool hasFriends;
  const _FriendPill({required this.hasFriends});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
              hasFriends ? '81 người bạn' : 'Thêm bạn bè',
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
      borderRadius: BorderRadius.circular(26),
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
                  color: Colors.black.withOpacity(0.45),
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
                color: Colors.black.withOpacity(0.45),
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

  const _ControlsBar({
    required this.onShutter,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: MyColors.cameraBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gallery (thư viện ảnh) bên trái – thu nhỏ lại
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MyColors.cameraHeaderBtnBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 22,
                color: MyColors.white,
              ),
            ),
          ),

          const SizedBox(width: 60),

          // Shutter — 3 layers: vàng → khoảng đen (mỏng hơn) → lõi trắng
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

          const SizedBox(width: 60),

          // Flip — icon xoay camera, thu nhỏ lại
          GestureDetector(
            onTap: onFlip,
            child: const Icon(
              Icons.flip_camera_ios,
              size: 36,
              color: MyColors.white,
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
          // Pill "9 Lịch sử"
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
                    color: Colors.black.withOpacity(0.15),
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
          const SizedBox(height: 8),
          // Arrow chevron xuống
          const Icon(
            Icons.expand_more,
            color: MyColors.white,
            size: 20,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
