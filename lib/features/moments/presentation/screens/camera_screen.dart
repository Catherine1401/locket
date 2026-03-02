import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/theme/colors.dart';

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
            // ── Header ─────────────────────────────────────────────
            _TopBar(hasFriends: false),
            const SizedBox(height: 16),

            // ── Viewfinder — 1:1, 4 corners rounded, 32px margins ──
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 48),
              child: AspectRatio(
                aspectRatio: 1,
                child: _Viewfinder(
                  controller: controller.value,
                  isInitialized: isInitialized.value,
                ),
              ),
            ),

            // ── Controls ────────────────────────────────────────────
            _ControlsBar(
              isFlashOn: isFlashOn.value,
              onFlashToggle: () async {
                isFlashOn.value = !isFlashOn.value;
                await controller.value?.setFlashMode(
                  isFlashOn.value ? FlashMode.torch : FlashMode.off,
                );
              },
              onShutter: () async {
                if (controller.value == null || !isInitialized.value) return;
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
                await _switchCamera(cameras.value, controller, isInitialized,
                    isFrontCamera.value);
              },
            ),

            // ── Footer flush to bottom ─────────────────────────────
            const Spacer(),
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
  const _TopBar({required this.hasFriends});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar — circle
            _CircleBtn(
              child: const Icon(Icons.person_outline,
                  color: MyColors.white, size: 20),
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
              hasFriends ? '1 Friend' : 'Add a Friend',
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
  const _Viewfinder({this.controller, required this.isInitialized});

  @override
  Widget build(BuildContext context) {
    // Full bleed, no margin. Only bottom 2 corners are rounded.
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox.expand(
        child: isInitialized && controller != null
            ? FittedBox(
                fit: BoxFit.cover,
                // previewSize trả về kích thước sensor gốc (landscape),
                // swap width↔height để có kích thước portrait thực tế.
                // FittedBox.cover scale lên để fill 1:1 và crop phần thừa.
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
      ),
    );
  }
}

// ─── Controls Bar ─────────────────────────────────────────────────────────────

class _ControlsBar extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final VoidCallback onShutter;
  final VoidCallback onFlip;

  const _ControlsBar({
    required this.isFlashOn,
    required this.onFlashToggle,
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
          // Flash — solid filled bolt
          GestureDetector(
            onTap: onFlashToggle,
            child: Icon(
              Icons.bolt,
              size: 36,
              color: isFlashOn ? MyColors.cameraFlashActive : MyColors.white,
            ),
          ),

          const SizedBox(width: 60),

          // Shutter — 3 layers: yellow ring → black gap → white fill
          GestureDetector(
            onTap: onShutter,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: MyColors.cameraShutterRing,  // darker gold #E6B800
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 60),

          // Flip — outlined camera + rotate arrow
          GestureDetector(
            onTap: onFlip,
            child: const Icon(
              Icons.flip_camera_ios_outlined,
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
          const SizedBox(height: 12),
          // History row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: MyColors.cameraHeaderBtnBg,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.landscape_outlined,
                  color: MyColors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'History',
                style: TextStyle(
                  color: MyColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: MyColors.cameraDragHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
