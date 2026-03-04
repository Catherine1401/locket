import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/injection.dart';
import 'package:locket/features/messages/presentation/riverpod/chat_provider.dart';
import 'package:locket/features/messages/presentation/riverpod/conversations_provider.dart';
import 'package:locket/features/messages/presentation/screens/chat_screen.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/presentation/riverpod/moment_feed_provider.dart';
import 'package:locket/features/moments/presentation/screens/grid_screen.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final String? initialMomentId;
  const FeedScreen({super.key, this.initialMomentId});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;
  bool _hasJumpedToInitial = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(momentFeedProvider);
    final myUserId = ref.watch(profileProvider).value?.id;
    final friends = ref.watch(friendsListProvider).value ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // Ngăn FeedScreen bị co lại gây lỗi overflow khi bàn phím hiện
      body: GestureDetector(
        // Vuốt xuống → back về camera
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 300) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────
              FeedTopBar(
                filterUserId: feedState.filterUserId,
                friends: friends,
                myAvatarUrl: ref.watch(profileProvider).value?.avatarUrl,
                onFilterChanged: (userId) =>
                    ref.read(momentFeedProvider.notifier).setFilter(userId),
              ),

              // ── Feed Content ─────────────────────────────────────────
              Expanded(
                child: feedState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: MyColors.bgButtonLogin, strokeWidth: 2))
                    : feedState.moments.isEmpty
                        ? const _EmptyFeed()
                        : Builder(
                            builder: (context) {
                              if (!_hasJumpedToInitial && widget.initialMomentId != null) {
                                final initPage = feedState.moments.indexWhere(
                                    (m) => m.id == widget.initialMomentId);
                                if (initPage > 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (_pageController.hasClients) {
                                      _pageController.jumpToPage(initPage);
                                    }
                                  });
                                }
                                _hasJumpedToInitial = true;
                              }
                              return NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n is ScrollEndNotification) {
                                final page = _pageController.page?.round() ?? 0;
                                if (page >= feedState.moments.length - 2) {
                                  ref.read(momentFeedProvider.notifier).loadMore();
                                }
                              } else if (n is OverscrollNotification) {
                                // Nếu chưa vuốt thả tay thì có thể trigger nhiều lần
                                if (n.overscroll < -10 || n.overscroll > 10) {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              }
                              return false;
                            },
                            child: PageView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              itemCount: feedState.moments.length,
                              itemBuilder: (context, index) {
                                final moment = feedState.moments[index];
                                final isOwn = moment.userId == myUserId;
                                String? authorAvatar;

                                if (isOwn) {
                                  authorAvatar = ref.watch(profileProvider).value?.avatarUrl;
                                } else {
                                  authorAvatar = friends.cast<Friend?>().firstWhere(
                                      (f) => f?.userId == moment.userId,
                                      orElse: () => null)?.avatar;
                                }

                                return _MomentPage(
                                  moment: moment,
                                  isOwn: isOwn,
                                  authorAvatar: authorAvatar,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),

              // ── Bottom Nav ─────────────────────────────────────────
              _BottomNav(
                onGridTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GridScreen()),
                ),
                onCameraTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Moment Page (1 item trong PageView) ────────────────────────────────

class _MomentPage extends StatelessWidget {
  final Moment moment;
  final bool isOwn;
  final String? authorAvatar; // Avatar của người gửi

  const _MomentPage({
    required this.moment,
    this.isOwn = false,
    this.authorAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth - 32; // padding 16 mỗi bên

    return Column(
      children: [
        // Đẩy khối ảnh ra giữa
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Ảnh vuông ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: moment.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const ColoredBox(color: Color(0xFF1A1A1A)),
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(color: Color(0xFF1A1A1A)),
                          ),

                          // Caption pill ở giữa-dưới ảnh
                          if (moment.caption != null &&
                              moment.caption!.isNotEmpty)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    moment.caption!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Avatar user + thời gian (Căn giữa) ─────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF444444),
                      backgroundImage: authorAvatar != null
                          ? NetworkImage(authorAvatar!)
                          : null,
                      child: authorAvatar == null
                          ? const Icon(Icons.person,
                              color: Colors.white70, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(moment.createdAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Message bar + emojis ────────────────────────────────────
        if (!isOwn)
          _MessageBar(moment: moment)
        else
          const SizedBox(height: 52),

        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}ph';
    if (diff.inHours < 24) return '${diff.inHours}g';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${(diff.inDays / 7).floor()} tuần';
  }
}

// ── Message Bar ────────────────────────────────────────────────────────────────

class _MessageBar extends StatelessWidget {
  final Moment moment;
  const _MessageBar({required this.moment});

  void _showReplyScreen(BuildContext context, {String? preset}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        barrierLabel: 'Reply',
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, _, __) => _ReplyMomentScreen(moment: moment, preset: preset),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF252525), // Pill background chung cho tất cả
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            // Text input (Gửi tin nhắn...)
            Expanded(
              child: GestureDetector(
                onTap: () => _showReplyScreen(context),
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent, // to make it clickable
                  child: const Text(
                    'Gửi tin nhắn...',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 15),
                  ),
                ),
              ),
            ),

            // Emojis bên trong cùng 1 pill
            _EmojiBtn('😂', onTap: () => _showReplyScreen(context, preset: '😂')),
            const SizedBox(width: 8),
            _EmojiBtn('💛', onTap: () => _showReplyScreen(context, preset: '💛')),
            const SizedBox(width: 8),
            _EmojiBtn('😡', onTap: () => _showReplyScreen(context, preset: '😡')),
            const SizedBox(width: 8),

            // Add emoji icon
            GestureDetector(
              onTap: () => _showReplyScreen(context),
              child: const Icon(
                Icons.add_reaction_outlined,
                color: Colors.white54,
                size: 22,
              ),
            ),
            const SizedBox(width: 16), // Padding phải
          ],
        ),
      ),
    );
  }
}

// ── Reply Moment Screen (Màn hình mờ có chứa ChatInputBar) ───────────────────

class _ReplyMomentScreen extends ConsumerStatefulWidget {
  final Moment moment;
  final String? preset;
  
  const _ReplyMomentScreen({required this.moment, this.preset});

  @override
  ConsumerState<_ReplyMomentScreen> createState() => _ReplyMomentScreenState();
}

class _ReplyMomentScreenState extends ConsumerState<_ReplyMomentScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.preset);
    if (widget.preset != null) {
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.preset!.length));
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final conversations = ref.read(conversationsProvider).value ?? [];
      final conversation = conversations.firstWhere(
        (c) => c.partnerId == widget.moment.userId,
        orElse: () => throw Exception('Conversation not found'),
      );

      await ref.read(chatProvider.notifier).sendMessage(
        conversation.id,
        text,
        replyToMomentId: widget.moment.id.toString(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Tắt Dialog màn mờ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã trả lời khoảnh khắc! 🚀'),
            backgroundColor: Color(0xFF333333),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể gửi tin nhắn')),
        );
      }
    } finally {
      if (mounted && _isSending) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          ChatInputBar(
            controller: _controller,
            focusNode: _focusNode,
            isSending: _isSending,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

class _EmojiBtn extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  const _EmojiBtn(this.emoji, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_album_outlined, color: Colors.white24, size: 56),
          SizedBox(height: 12),
          Text('Chưa có hoạt động nào',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(height: 6),
          Text(
            'Khi bạn bè đăng ảnh sẽ xuất hiện ở đây',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class FeedTopBar extends ConsumerWidget {
  final String? filterUserId;
  final List<Friend> friends;
  final String? myAvatarUrl;
  final ValueChanged<String?> onFilterChanged;

  const FeedTopBar({
    super.key,
    required this.filterUserId,
    required this.friends,
    this.myAvatarUrl,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentName = filterUserId == null
        ? 'Mọi người'
        : (friends
            .firstWhere(
              (f) => f.userId == filterUserId,
              orElse: () => Friend(
                  id: '', userId: filterUserId!, name: 'Bạn bè', avatar: null),
            )
            .name);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // Avatar trái (Người đang lướt feed)
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF333333),
            backgroundImage:
                myAvatarUrl != null ? NetworkImage(myAvatarUrl!) : null,
            child: myAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.white54, size: 18)
                : null,
          ),

          // Dropdown giữa
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Chat icon phải
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF333333),
            ),
            child: const Icon(Icons.chat_bubble_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        friends: friends,
        currentId: filterUserId,
        onSelect: onFilterChanged,
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  final List<Friend> friends;
  final String? currentId;
  final ValueChanged<String?> onSelect;

  const _FilterSheet({
    required this.friends,
    this.currentId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          _FilterItem(
            label: 'Mọi người',
            isSelected: currentId == null,
            onTap: () {
              onSelect(null);
              Navigator.pop(context);
            },
          ),
          ...friends.map((f) => _FilterItem(
                label: f.name,
                avatarUrl: f.avatar,
                isSelected: currentId == f.userId,
                onTap: () {
                  onSelect(f.userId);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String label;
  final String? avatarUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterItem(
      {required this.label,
      this.avatarUrl,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF444444),
        backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(label[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13))
            : null,
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: MyColors.bgButtonLogin, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final VoidCallback? onGridTap;
  final VoidCallback? onCameraTap;

  const _BottomNav({this.onGridTap, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Grid / apps icon
          GestureDetector(
            onTap: onGridTap,
            child: const Icon(Icons.grid_view_rounded,
                color: Colors.white54, size: 28),
          ),

          // Camera button (vòng tròn vàng)
          GestureDetector(
            onTap: onCameraTap ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MyColors.bgButtonLogin, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8E8E8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Share icon
          GestureDetector(
            onTap: () {},
            child:
                const Icon(Icons.ios_share, color: Colors.white54, size: 26),
          ),
        ],
      ),
    );
  }
}
