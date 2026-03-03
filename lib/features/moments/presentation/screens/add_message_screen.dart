import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';

/// Screen chỉnh sửa caption: ảnh preview ở giữa, TextField đè lên ảnh.
/// Không có nút Done — tự pop và trả text khi bàn phím đóng hoặc submit.
class AddMessageScreen extends StatefulWidget {
  final String imagePath;
  final String initialMessage;

  const AddMessageScreen({
    super.key,
    required this.imagePath,
    this.initialMessage = '',
  });

  @override
  State<AddMessageScreen> createState() => _AddMessageScreenState();
}

class _AddMessageScreenState extends State<AddMessageScreen> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialMessage);
    _focusNode = FocusNode();

    // Tự lưu và pop khi bàn phím đóng
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _popWithResult();
      }
    });

    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _popWithResult() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_ctrl.text);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.cameraBackground,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        // Tap ngoài ảnh → đóng bàn phím → tự lưu
        onTap: () => _focusNode.unfocus(),
        child: SafeArea(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ảnh preview 1:1 căn giữa màn hình
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

                // TextField đè lên ảnh ở phía dưới
                Positioned(
                  bottom: 24,
                  left: 40,
                  right: 40,
                  child: GestureDetector(
                    // Ngăn tap TextField truyền lên GestureDetector ngoài
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextField(
                        controller: _ctrl,
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
                        // Submit (Enter/Done) → unfocus → focusNode listener tự pop
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
