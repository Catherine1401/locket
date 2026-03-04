import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/domain/entities/message.dart';
import 'package:locket/features/messages/presentation/riverpod/chat_provider.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';


String _formatTimeAgoShort(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes > 0 ? diff.inMinutes : 1}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

String _formatTimeDetail(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  if (h >= 12) {
    final hr = h == 12 ? 12 : h - 12;
    return '$hr:$m CH';
  } else {
    final hr = h == 0 ? 12 : h;
    return '$hr:$m SA';
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final Conversation? conversation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Tải tin nhắn ban đầu
    Future.microtask(() {
      ref.read(chatProvider.notifier).loadInitial(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 80) {
      final chatState = ref.read(chatProvider);
      if (chatState.hasMore && !chatState.isLoadingMore) {
        ref.read(chatProvider.notifier).loadMore(widget.conversationId);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _textController.clear();
    try {
      await ref
          .read(chatProvider.notifier)
          .sendMessage(widget.conversationId, text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final myProfile = ref.watch(profileProvider).value;
    final myId = myProfile?.id ?? '';

    final partnerName = widget.conversation?.partnerName ?? 'Tin nhắn';
    final partnerAvatar = widget.conversation?.partnerAvatar;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────
            _AppBar(
              partnerName: partnerName,
              partnerAvatar: partnerAvatar,
            ),

            const Divider(color: Color(0xFF222222), height: 1, thickness: 1),

            // ── Messages List ───────────────────────────────────────
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : chatState.messages.isEmpty
                      ? const _EmptyChat()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: chatState.messages.length +
                              (chatState.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (chatState.isLoadingMore && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white38,
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final msgIndex =
                                chatState.isLoadingMore ? index - 1 : index;
                            final msg = chatState.messages[msgIndex];
                            final isMe = msg.senderId == myId;

                            // Check nếu cần hiển thị thời gian (cách 5 phút)
                            final showTime = msgIndex == 0 ||
                                msg.createdAt
                                        .difference(chatState
                                            .messages[msgIndex - 1].createdAt)
                                        .inMinutes
                                        .abs() >=
                                    5;

                            // Avater chỉ hiện ở tin nhắn cuối cùng của một chuỗi
                            final isLastInGroup = msgIndex == chatState.messages.length - 1 ||
                                chatState.messages[msgIndex + 1].senderId != msg.senderId ||
                                chatState.messages[msgIndex + 1].createdAt.difference(msg.createdAt).inMinutes.abs() >= 5;

                            return Column(
                              children: [
                                if (showTime)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Text(
                                      _formatMessageTime(msg.createdAt),
                                      style: const TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                _MessageBubble(
                                  content: msg.content,
                                  isMe: isMe,
                                  showAvatar: !isMe && isLastInGroup,
                                  partnerAvatar: partnerAvatar,
                                  partnerName: partnerName,
                                  replyToMoment: msg.replyToMoment,
                                ),
                                const SizedBox(height: 4),
                              ],
                            );
                          },
                        ),
            ),

            // ── Input Bar ───────────────────────────────────────────
            ChatInputBar(
              controller: _textController,
              isSending: _isSending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 1) {
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dt.month - 1];
      return '$month ${dt.day}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final String partnerName;
  final String? partnerAvatar;

  const _AppBar({required this.partnerName, this.partnerAvatar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniAvatar(url: partnerAvatar, name: partnerName),
              const SizedBox(width: 8),
              Text(
                partnerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final bool showAvatar;
  final String? partnerAvatar;
  final String? partnerName;
  final ReplyMoment? replyToMoment;

  const _MessageBubble({
    required this.content,
    required this.isMe,
    this.showAvatar = false,
    this.partnerAvatar,
    this.partnerName,
    this.replyToMoment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              _MiniAvatar(url: partnerAvatar, name: partnerName ?? '')
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (replyToMoment != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (replyToMoment!.imageUrl != null)
                              CachedNetworkImage(
                                imageUrl: replyToMoment!.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const ColoredBox(color: Colors.black26),
                                errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black26),
                              ),
                            // Top-left overlay: Avatar, Name, Time ago
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (replyToMoment!.authorAvatar != null)
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundImage: NetworkImage(replyToMoment!.authorAvatar!),
                                      )
                                    else
                                      const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.person, size: 12, color: Colors.white),
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      replyToMoment!.authorName ?? 'Unknown',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    if (replyToMoment!.createdAt != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatTimeAgoShort(replyToMoment!.createdAt!),
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            // Bottom-center overlay: Clock icon + Time
                            if (replyToMoment!.createdAt != null)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_filled, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatTimeDetail(replyToMoment!.createdAt!),
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFE5E5E5) : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? 8 : 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 120, minHeight: 48),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.only(left: 18, right: 6, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, height: 1.3),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Send message...',
                    hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: _hasText && !widget.isSending
                    ? const Color(0xFF555555)
                    : const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (_hasText && !widget.isSending) ? widget.onSend : null,
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: widget.isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            color: _hasText ? Colors.white : const Color(0xFF666666),
                            size: 20,
                          ),
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

// ── Mini Avatar ───────────────────────────────────────────────────────────────

class _MiniAvatar extends StatelessWidget {
  final String? url;
  final String name;

  const _MiniAvatar({this.url, required this.name});

  static const _palette = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFFF922B),
    Color(0xFFCC5DE8),
  ];

  Color get _bg => name.isEmpty
      ? const Color(0xFF3A3A3A)
      : _palette[name.codeUnitAt(0) % _palette.length];

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: _bg,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: _bg,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          width: 32,
          height: 32,
          errorWidget: (_, __, ___) => Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// ── Empty Chat ────────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👋', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'Hãy gửi tin nhắn đầu tiên!',
            style: TextStyle(color: Color(0xFF666666), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
