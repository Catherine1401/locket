import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/presentation/riverpod/friends_provider.dart';
import 'package:locket/features/moments/injection.dart';

class MomentPreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const MomentPreviewScreen({super.key, required this.imagePath});

  @override
  ConsumerState<MomentPreviewScreen> createState() =>
      _MomentPreviewScreenState();
}

class _MomentPreviewScreenState extends ConsumerState<MomentPreviewScreen> {
  // null = "All", otherwise a set of selected friendIds
  Set<String>? _selectedFriendIds; // null means "All"
  final TextEditingController _messageCtrl = TextEditingController();
  bool _isSending = false;
  String? _errorMsg;

  bool get _sendToAll => _selectedFriendIds == null;
  int get _captionWordCount => _countWords(_messageCtrl.text);

  static int _countWords(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            _Header(
              onDownload: _onDownload,
              onClose: () => Navigator.of(context).pop(),
            ),

            // ── Error banner ────────────────────────────────────────
            if (_errorMsg != null)
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  _errorMsg!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),

            // ── Main content centered ────────────────────────────────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Tính kích thước ảnh: không vượt quá width và chiều cao còn lại
                  // Trừ đi: page dots (20) + word count (20) + action bar (100) + paddings (~50)
                  const reservedHeight = 190.0;
                  final maxPhotoSize = (constraints.maxHeight - reservedHeight)
                      .clamp(160.0, constraints.maxWidth);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Photo preview 1:1
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _PhotoPreview(
                          imagePath: widget.imagePath,
                          message: _messageCtrl.text,
                          onAddMessage: _onAddMessage,
                          size: maxPhotoSize,
                        ),
                      ),

                      // Page dots
                      const _PageDots(total: 5, active: 0),
                      const SizedBox(height: 6),
                      Text(
                        '${_captionWordCount.clamp(0, 999)}/100 từ',
                        style: TextStyle(
                          color: _captionWordCount > 100
                              ? Colors.redAccent
                              : MyColors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action bar
                      _ActionBar(
                        isSending: _isSending,
                        onClose: () => Navigator.of(context).pop(),
                        onSend: () => _showSelectFriendsSheet(friendsAsync),
                        onAddText: _onAddMessage,
                      ),
                    ],
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _onSend() async {
    if (_captionWordCount > 100) {
      setState(() { _errorMsg = 'Caption tối đa 100 từ'; });
      return;
    }

    setState(() {
      _isSending = true;
      _errorMsg = null;
    });

    try {
      final useCase = await ref.read(createMomentUseCaseProvider.future);
      await useCase.call(
        widget.imagePath,
        _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isSending = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = 'Gửi thất bại. Vui lòng thử lại.'; _isSending = false; });
    }
  }

  // ── Select Friends Bottom Sheet ──────────────────────────────────────────────

  void _showSelectFriendsSheet(AsyncValue<List<Friend>> friendsAsync) {
    // Local copy of selection state for the sheet
    Set<String>? sheetSelectedIds = _selectedFriendIds == null
        ? null
        : Set<String>.from(_selectedFriendIds!);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final friends = friendsAsync.value ?? [];
          final sendToAll = sheetSelectedIds == null;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle bar ──────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Title ───────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Người bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Divider(color: Color(0xFF2C2C2E), height: 1),

                // ── Friend list ─────────────────────────────────────
                Flexible(
                  child: friendsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Không tải được danh sách', style: TextStyle(color: Colors.white70)),
                    ),
                    data: (friends) => ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // "Tất cả" option
                        _FriendSheetTile(
                          avatar: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3A3A3C),
                            ),
                            child: const Icon(Icons.group, color: Colors.white, size: 26),
                          ),
                          name: 'Tất cả',
                          isSelected: sendToAll,
                          onTap: () => setSheetState(() => sheetSelectedIds = null),
                        ),
                        ...friends.map((f) {
                          final isSelected = sheetSelectedIds?.contains(f.userId) ?? false;
                          return _FriendSheetTile(
                            avatar: _FriendAvatar(friend: f),
                            name: f.name,
                            isSelected: isSelected,
                            onTap: () => setSheetState(() {
                              sheetSelectedIds ??= {};
                              final ids = Set<String>.from(sheetSelectedIds!);
                              if (ids.contains(f.userId)) {
                                ids.remove(f.userId);
                                sheetSelectedIds = ids.isEmpty ? null : ids;
                              } else {
                                ids.add(f.userId);
                                sheetSelectedIds = ids;
                              }
                            }),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // ── Send button ─────────────────────────────────────
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD60A),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Apply selection to parent state
                          setState(() => _selectedFriendIds = sheetSelectedIds);
                          Navigator.pop(ctx);
                          _onSend();
                        },
                        child: const Text(
                          'Gửi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onDownload() async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: false);
      }
      await Gal.putImage(widget.imagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào thư viện ảnh'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu ảnh'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onAddMessage() {
    Navigator.of(context)
        .push<String>(
          MaterialPageRoute(
            builder: (_) => MomentMessageScreen(
              imagePath: widget.imagePath,
              initialText: _messageCtrl.text,
            ),
          ),
        )
        .then((value) {
      if (value != null && mounted) {
        setState(() => _messageCtrl.text = value);
      }
    });
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onClose;
  const _Header({required this.onDownload, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            // invisible spacer equal to download icon
            const SizedBox(width: 24, height: 24),
            const Spacer(),
            const Text(
              'Send to...',
              style: TextStyle(
                color: MyColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDownload,
              child: const Icon(
                Icons.download_rounded,
                color: MyColors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Photo Preview ────────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  final String imagePath;
  final String message;
  final VoidCallback onAddMessage;
  final double size;

  const _PhotoPreview({
    required this.imagePath,
    required this.message,
    required this.onAddMessage,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover),

            // "Add a message" overlay
            Positioned(
              bottom: 24,
              left: 40,
              right: 40,
              child: GestureDetector(
                onTap: onAddMessage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    message.isEmpty ? 'Add a message' : message,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: message.isEmpty
                          ? MyColors.white.withOpacity(0.75)
                          : MyColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

// ─── Message Overlay Screen ───────────────────────────────────────────────────

class MomentMessageScreen extends StatefulWidget {
  final String imagePath;
  final String initialText;

  const MomentMessageScreen({
    super.key,
    required this.imagePath,
    required this.initialText,
  });

  @override
  State<MomentMessageScreen> createState() => _MomentMessageScreenState();
}

class _MomentMessageScreenState extends State<MomentMessageScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(_controller.text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        child: SafeArea(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 40,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MyColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a message',
                          hintStyle: TextStyle(
                            color: MyColors.white.withOpacity(0.75),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _focusNode.unfocus(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Page Dots ────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int total;
  final int active;
  const _PageDots({required this.total, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? MyColors.white
                : MyColors.white.withOpacity(0.35),
          ),
        );
      }),
    );
  }
}

// ─── Action Bar ───────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final bool isSending;
  final VoidCallback onClose;
  final VoidCallback onSend;
  final VoidCallback onAddText;

  const _ActionBar({
    required this.isSending,
    required this.onClose,
    required this.onSend,
    required this.onAddText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // X — discard
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: MyColors.white, size: 32),
          ),

          // Send button
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4A4A4A),
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MyColors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: MyColors.white,
                      size: 34,
                    ),
            ),
          ),

          // Aa text overlay
          GestureDetector(
            onTap: onAddText,
            child: const _AaIcon(),
          ),
        ],
      ),
    );
  }
}

class _AaIcon extends StatelessWidget {
  const _AaIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Text(
          'Aa',
          style: TextStyle(
            color: MyColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: const Icon(Icons.auto_awesome, color: MyColors.white, size: 8),
          ),
        ),
      ],
    );
  }
}

// ─── Friends Row ──────────────────────────────────────────────────────────────

class _FriendsRow extends StatelessWidget {
  final AsyncValue<List<Friend>> friendsAsync;
  final bool sendToAll;
  final Set<String> selectedFriendIds;
  final VoidCallback onToggleAll;
  final ValueChanged<Friend> onToggleFriend;

  const _FriendsRow({
    required this.friendsAsync,
    required this.sendToAll,
    required this.selectedFriendIds,
    required this.onToggleAll,
    required this.onToggleFriend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: friendsAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MyColors.white,
            ),
          ),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Không tải được danh sách bạn bè',
            style: TextStyle(color: MyColors.white, fontSize: 12),
          ),
        ),
        data: (friends) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            // "All" button
            _FriendChip(
              label: 'Tất cả',
              isSelected: sendToAll,
              onTap: onToggleAll,
              child: Icon(
                Icons.group,
                color:
                    sendToAll ? MyColors.cameraFlashActive : MyColors.white,
                size: 26,
              ),
            ),

            // Real friends
            ...friends.map(
              (f) => _FriendChip(
                label: f.name.split(' ').last, // first name only
                isSelected: selectedFriendIds.contains(f.userId),
                onTap: () => onToggleFriend(f),
                child: _FriendAvatar(friend: f),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final Friend friend;
  const _FriendAvatar({required this.friend});

  @override
  Widget build(BuildContext context) {
    final url = friend.avatar;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (_, __) => const _FallbackIcon(),
          errorWidget: (_, __, ___) => const _FallbackIcon(),
        ),
      );
    }
    return const _FallbackIcon();
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();
  @override
  Widget build(BuildContext context) => const Icon(
        Icons.person_outline,
        color: MyColors.white,
        size: 24,
      );
}

class _FriendChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _FriendChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.cameraHeaderBtnBg,
                border: isSelected
                    ? Border.all(
                        color: MyColors.cameraFlashActive,
                        width: 2.5,
                      )
                    : null,
              ),
              child: Center(child: child),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? MyColors.cameraFlashActive
                    : MyColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Friend Sheet Tile ────────────────────────────────────────────────────────

class _FriendSheetTile extends StatelessWidget {
  final Widget avatar;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _FriendSheetTile({
    required this.avatar,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SizedBox(width: 52, height: 52, child: avatar),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFFD60A) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD60A) : const Color(0xFF555555),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
