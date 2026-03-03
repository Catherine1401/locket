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
  bool _isSending = false;
  Map<String, dynamic>? _targetData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final useCase =
          await ref.read(getUserByShareCodeUseCaseProvider.future);
      final data = await useCase.call(widget.shareCode);
      if (mounted) {
        setState(() {
          _targetData = data;
          if (data == null) {
            _error = 'Người dùng không tồn tại hoặc Link không hợp lệ.';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải thông tin. Vui lòng thử lại sau.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onActionPressed() async {
    if (_targetData == null) return;
    final status = _targetData!['status'] as String?;
    final targetUser = _targetData!['user'] as Map<String, dynamic>;

    if (status == 'stranger') {
      // Send friend request
      setState(() => _isSending = true);
      try {
        final sendUseCase =
            await ref.read(sendFriendRequestUseCaseProvider.future);
        final success = await sendUseCase.call(targetUser['id']);
        if (success && mounted) {
          setState(() {
            _targetData!['status'] = 'outgoing';
            _isSending = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSending = false);
      }
    } else if (status == 'incoming') {
      // Accept friend request
      setState(() => _isSending = true);
      try {
        final respondUseCase = await ref.read(respondFriendRequestUseCaseProvider.future);
        final success = await respondUseCase.call(targetUser['id'], 'accept');
        if (success && mounted) {
          setState(() {
            _targetData!['status'] = 'friend';
            _isSending = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  String _getButtonText(String? status) {
    switch (status) {
      case 'stranger':
        return 'Thêm bạn bè';
      case 'outgoing':
        return 'Đã gửi yêu cầu';
      case 'incoming':
        return 'Chấp nhận';
      case 'friend':
        return 'Đã là bạn bè';
      default:
        return 'Thêm bạn bè';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
            
            // Content
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: MyColors.bgButtonLogin)
                  : _error != null
                      ? Text(_error!, style: const TextStyle(color: Colors.white))
                      : _buildUserInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    if (_targetData == null) return const SizedBox();
    
    final user = _targetData!['user'] as Map<String, dynamic>;
    final status = _targetData!['status'] as String?;
    final avatarUrl = user['avatarUrl'] as String?;
    final displayName = user['displayName'] as String? ?? 'Người dùng';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar with border
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MyColors.bgButtonLogin, width: 4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipOval(
              child: avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.person, color: Colors.white, size: 60),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white, size: 60),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Name
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        
        // Action Button
        GestureDetector(
          onTap: _isSending || status != 'stranger' ? null : _onActionPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: status == 'stranger' ? MyColors.bgButtonLogin : Colors.grey[800],
              borderRadius: BorderRadius.circular(999),
            ),
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _getButtonText(status),
                    style: TextStyle(
                      color: status == 'stranger' ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
