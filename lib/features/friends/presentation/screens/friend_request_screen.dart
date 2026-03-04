import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/injection.dart';

class FriendRequestScreen extends ConsumerStatefulWidget {
  final String shareCode;

  const FriendRequestScreen({super.key, required this.shareCode});

  @override
  ConsumerState<FriendRequestScreen> createState() =>
      _FriendRequestScreenState();
}

class _FriendRequestScreenState extends ConsumerState<FriendRequestScreen> {
  bool _isLoading = true;
  bool _isActing = false;
  Map<String, dynamic>? _targetData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final useCase = await ref.read(getUserByShareCodeUseCaseProvider.future);
      final data = await useCase.call(widget.shareCode);
      if (mounted) {
        setState(() {
          _targetData = data;
          _error = data == null
              ? 'Người dùng không tồn tại hoặc link không hợp lệ.'
              : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải thông tin. Vui lòng thử lại.';
          _isLoading = false;
        });
      }
    }
  }

  String? get _status => _targetData?['status'] as String?;

  Future<void> _onSendRequest() async {
    if (_targetData == null) return;
    final targetUser = _targetData!['user'] as Map<String, dynamic>;
    setState(() => _isActing = true);
    try {
      final useCase = await ref.read(sendFriendRequestUseCaseProvider.future);
      final ok = await useCase.call(targetUser['id'].toString());
      if (ok && mounted) {
        setState(() {
          _targetData!['status'] = 'outgoing';
          _isActing = false;
        });
      } else {
        if (mounted) setState(() => _isActing = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _onAcceptRequest() async {
    if (_targetData == null) return;
    final targetUser = _targetData!['user'] as Map<String, dynamic>;
    // incoming: requestId = targetUser id (server trả theo share code)
    // Cần request_id — server trả trong response bằng friendship status
    // Thực tế backend dùng friendRequest.id từ bảng request_friends
    // Ở đây ta dùng userId của target để gọi respond nếu không có requestId
    // TODO: khi backend trả request_id trong /users/:sharecode thì dùng trực tiếp
    setState(() => _isActing = true);
    try {
      final useCase =
          await ref.read(respondFriendRequestUseCaseProvider.future);
      // Tạm thời dùng userId làm requestId — cần backend trả request_id
      final ok = await useCase.call(targetUser['id'].toString(), 'accept');
      if (ok && mounted) {
        setState(() {
          _targetData!['status'] = 'friend';
          _isActing = false;
        });
      } else {
        if (mounted) setState(() => _isActing = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _onClose() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Close button ─────────────────────────────────────
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: _onClose,
              ),
            ),

            // ── Content ──────────────────────────────────────────
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: MyColors.bgButtonLogin, strokeWidth: 2)
                  : _error != null
                      ? _buildError()
                      : _buildUserCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link_off_rounded,
                color: Colors.grey, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _fetchUser,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Thử lại',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    if (_targetData == null) return const SizedBox();
    final user = _targetData!['user'] as Map<String, dynamic>;
    final avatarUrl = user['avatarUrl'] as String?;
    final displayName = user['displayName'] as String? ?? 'Người dùng';
    final status = _status;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Avatar ────────────────────────────────────────────
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MyColors.bgButtonLogin, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildAvatarPlaceholder(),
                        errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                      )
                    : _buildAvatarPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Name ──────────────────────────────────────────────
          Text(
            displayName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          if (status == 'friend')
            const Text('Đã là bạn bè',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 36),

          // ── Main action button ────────────────────────────────
          if (status != 'friend') _buildActionButton(status),

          // ── Reject button for incoming ────────────────────────
          if (status == 'incoming') ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isActing ? null : () => _onClose(),
              child: const Text(
                'Bỏ qua',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String? status) {
    final isActive = status == 'stranger' || status == 'incoming';
    final label = _getButtonLabel(status);

    return GestureDetector(
      onTap: isActive && !_isActing
          ? (status == 'stranger' ? _onSendRequest : _onAcceptRequest)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? MyColors.bgButtonLogin
              : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(999),
        ),
        child: _isActing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _getButtonLabel(String? status) {
    switch (status) {
      case 'stranger':
        return 'Thêm bạn bè';
      case 'outgoing':
        return 'Đã gửi yêu cầu';
      case 'incoming':
        return 'Chấp nhận';
      default:
        return 'Thêm bạn bè';
    }
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: const Color(0xFF2C2C2C),
      child: const Icon(Icons.person_outline, color: Colors.grey, size: 60),
    );
  }
}
