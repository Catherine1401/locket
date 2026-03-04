import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/presentation/riverpod/conversations_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConvs = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => ref.read(rootPageControllerProvider).animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  const Text(
                    'Tin nhắn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: asyncConvs.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFF555555), size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Không tải được tin nhắn',
                        style: const TextStyle(
                            color: Color(0xFF888888), fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.read(conversationsProvider.notifier).reload(),
                        child: const Text('Thử lại',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                data: (conversations) => conversations.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: const Color(0xFF2C2C2C),
                        onRefresh: () =>
                            ref.read(conversationsProvider.notifier).reload(),
                        child: ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            return _ConversationTile(
                              conversation: conv,
                              onTap: () => context.push(
                                '/conversations/${conv.id}',
                                extra: conv,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conversation Tile ─────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = conversation.isUnread;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white10,
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────────────
              _Avatar(
                url: conversation.partnerAvatar,
                name: conversation.partnerName,
                radius: 28,
                showUnreadRing: isUnread,
              ),
              const SizedBox(width: 14),

              // ── Name + Last message ──────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Name + time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            conversation.partnerName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.lastMessageAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(conversation.lastMessageAt!),
                            style: TextStyle(
                              color: isUnread ? Colors.white : const Color(0xFF666666),
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Last message
                    Text(
                      conversation.lastMessage ?? 'Bắt đầu cuộc trò chuyện',
                      style: TextStyle(
                        color: isUnread
                            ? Colors.white
                            : conversation.lastMessage != null
                                ? const Color(0xFF999999)
                                : const Color(0xFF555555),
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Unread dot OR Chevron ──────────────────────────────
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB800),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF444444),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 365) {
      return '${(diff.inDays / 365).floor()} năm';
    } else if (diff.inDays >= 30) {
      // Hiển thị ngày tháng như "23 thg 1"
      return '${dt.day} thg ${dt.month}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}ngày';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}ph';
    } else {
      return 'Vừa xong';
    }
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;

  final bool showUnreadRing;

  const _Avatar({this.url, required this.name, required this.radius, this.showUnreadRing = false});

  static const _palette = [
    Color(0xFFE57373), // red
    Color(0xFF81C784), // green
    Color(0xFF64B5F6), // blue
    Color(0xFFFFB74D), // orange
    Color(0xFFBA68C8), // purple
    Color(0xFF4DD0E1), // cyan
    Color(0xFFF06292), // pink
    Color(0xFF90A4AE), // grey
  ];

  Color get _bg => name.isEmpty
      ? const Color(0xFF3A3A3A)
      : _palette[name.codeUnitAt(0) % _palette.length];

  Widget _fallback() => CircleAvatar(
        radius: radius,
        backgroundColor: _bg,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.75,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _avatarWidget() {
    if (url == null || url!.isEmpty) return _fallback();
    return CircleAvatar(
      radius: radius,
      backgroundColor: _bg,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          placeholder: (_, __) => _fallback(),
          errorWidget: (_, __, ___) => _fallback(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showUnreadRing) return _avatarWidget();
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFB800), width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: _avatarWidget(),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF444444),
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có tin nhắn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kết bạn để bắt đầu nhắn tin nhé!',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
