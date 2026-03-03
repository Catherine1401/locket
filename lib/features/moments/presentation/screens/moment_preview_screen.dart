import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';

class MomentPreviewScreen extends StatefulWidget {
  final String imagePath;

  const MomentPreviewScreen({super.key, required this.imagePath});

  @override
  State<MomentPreviewScreen> createState() => _MomentPreviewScreenState();
}

class _MomentPreviewScreenState extends State<MomentPreviewScreen> {
  bool _sendToAll = true;
  final TextEditingController _messageCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            _Header(
              onDownload: _onDownload,
              onClose: () => Navigator.of(context).pop(),
            ),

            // Khối preview + control được canh giữa màn hình
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Photo preview — 1:1 ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _PhotoPreview(
                      imagePath: widget.imagePath,
                      message: _messageCtrl.text,
                      onAddMessage: _onAddMessage,
                    ),
                  ),

                  // ── Page indicator dots ──────────────────────────
                  const _PageDots(total: 5, active: 0),
                  const SizedBox(height: 16),

                  // ── Action bar ───────────────────────────────────
                  _ActionBar(
                    isSending: _isSending,
                    onClose: () => Navigator.of(context).pop(),
                    onSend: _onSend,
                    onAddText: _onAddMessage,
                  ),
                ],
              ),
            ),

            // ── Friends selection luôn sát đáy ─────────────────────
            _FriendsRow(
              sendToAll: _sendToAll,
              onToggleAll: () => setState(() => _sendToAll = !_sendToAll),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSend() async {
    setState(() => _isSending = true);
    // TODO: call create moment API
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onDownload() {
    // TODO: save to gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to gallery')),
    );
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
        setState(() {
          _messageCtrl.text = value;
        });
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
            // Nút đóng (ẩn, chỉ để giữ layout cân đối nếu cần)
            GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 24,
              ),
            ),
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

  const _PhotoPreview({
    required this.imagePath,
    required this.message,
    required this.onAddMessage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.file(File(imagePath), fit: BoxFit.cover),

            // "Add a message" overlay button
            Positioned(
              bottom: 24,
              left: 40,
              right: 40,
              child: GestureDetector(
                onTap: onAddMessage,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

/// Screen dedicated to typing message with keyboard visible
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

    // Auto-pop với text khi bàn phím đóng
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
        // Tap ngoài → unfocus → auto-pop
        onTap: () => _focusNode.unfocus(),
        child: SafeArea(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ảnh 1:1 ở giữa màn hình
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

                // TextField đè lên ảnh phía dưới
                Positioned(
                  bottom: 24,
                  left: 40,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {}, // chặn tap truyền lên GestureDetector ngoài
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
          // X — discard (to hơn)
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              color: MyColors.white,
              size: 32,
            ),
          ),

          // Send button — vòng tròn lớn giống shutter
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

          // Aa+ — add text overlay (to hơn)
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
            child: const Icon(Icons.auto_awesome,
                color: MyColors.white, size: 8),
          ),
        ),
      ],
    );
  }
}

// ─── Friends Row ──────────────────────────────────────────────────────────────

class _FriendsRow extends StatelessWidget {
  final bool sendToAll;
  final VoidCallback onToggleAll;

  const _FriendsRow({required this.sendToAll, required this.onToggleAll});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // "All" button
          _FriendChip(
            label: 'All',
            isSelected: sendToAll,
            onTap: onToggleAll,
            child: Icon(
              Icons.group,
              color: sendToAll
                  ? MyColors.cameraFlashActive
                  : MyColors.white,
              size: 26,
            ),
          ),
          // Placeholder: friends list (no friends yet)
          // TODO: load from friendsProvider
        ],
      ),
    );
  }
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
