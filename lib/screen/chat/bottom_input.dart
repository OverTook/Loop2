import 'package:flutter/material.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:loop/const/constants.dart';
import 'package:loop/screen/chat/bottom_input/album.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../manager/temp_manager.dart';

class BottomInputWidget extends StatefulWidget {
  const BottomInputWidget({super.key});

  @override
  State<StatefulWidget> createState() => _BottomInputWidgetState();

}
class _BottomInputWidgetState extends State<BottomInputWidget> with SingleTickerProviderStateMixin {

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _controller;
  late double _keyboardHeight;

  bool _isSheetOpen = false;
  bool _isKeyboardOpen = false;
  bool _reopenKeyboard = false;
  bool _isAlbumOpen = false;

  @override
  void initState() {
    super.initState();
    _keyboardHeight = TempManager().getKeyboardHeight();
    _controller = AnimationController(
      duration: const Duration(milliseconds: Constants.bottomSheetAnimationTime),
      vsync: this,
    );

    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) async {
      if(_keyboardHeight != height && height > 1) { // 키보드 높이 변경인 경우 처리
        _keyboardHeight = height;
        await TempManager().setKeyboardHeight(height);
      }

      setState(() {
        _isKeyboardOpen = height > 1;
        if(_isKeyboardOpen) {
          _isSheetOpen = false;
          _reopenKeyboard = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleBottomSheet() {
    setState(() {
      _isSheetOpen = !_isSheetOpen;
      if(_isKeyboardOpen && _isSheetOpen) {
        _isKeyboardOpen = false;
        _reopenKeyboard = true;
        FocusManager.instance.primaryFocus?.unfocus();
        return;
      }

      if (_isSheetOpen) {
        _controller.forward();
      } else if(!_reopenKeyboard) {
        _controller.reverse();
      } else {
        _isKeyboardOpen = true;
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAlbumOpen && !_isSheetOpen && !_isKeyboardOpen,
      onPopInvokedWithResult: (b, _) {
        if(_isAlbumOpen) {
          setState(() {
            _isAlbumOpen = false;
          });
          return;
        }

        if(_isSheetOpen) {
          setState(() {
            _isSheetOpen = false;
          });
          return;
        }
      },
      child: _isAlbumOpen ? _buildGallery() : _buildBottomInput(),
    );
  }

  Widget _buildGallery() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: Constants.bottomSheetAnimationTime),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: _isSheetOpen || _isKeyboardOpen ? _keyboardHeight : 0),
            child: Container(
              height: 47,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAlbumOpen = false;
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 15,
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),

        // BottomSheet 영역
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: Constants.bottomSheetAnimationTime),
            curve: Curves.easeOutCubic,
            height: _isSheetOpen || _isKeyboardOpen ? _keyboardHeight : 0,
            color: Colors.grey[200],
            child: const MediaGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInput() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: Constants.bottomSheetAnimationTime),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: _isSheetOpen || _isKeyboardOpen ? _keyboardHeight : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              color: Colors.white,
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _toggleBottomSheet,
                    child: AnimatedRotation(
                      turns: _isSheetOpen ? 0.125 : 0, // 45도 회전
                      duration: const Duration(milliseconds: 100),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 15,
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.grey,
                          size: 25,
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: '메시지 입력',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorHeight: 18,
                      ),

                    ),
                  ),
                  const SizedBox(width: 6), // 간격 추가
                ],
              ),
            ),
          ),
        ),

        // BottomSheet 영역
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: Constants.bottomSheetAnimationTime),
            curve: Curves.easeOutCubic,
            height: _isSheetOpen || _isKeyboardOpen ? _keyboardHeight : 0,
            color: Colors.grey[200],
            child: _isSheetOpen ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                children: [
                  _buildBottomSheetItem(
                    icon: Icons.post_add,
                    backgroundColor: Colors.green,
                    label: "게시물 작성",
                    onTap: () {
                      // 게시물 작성 기능
                    },
                  ),
                  _buildBottomSheetItem(
                    icon: Icons.photo_album,
                    backgroundColor: Colors.blue,
                    label: "앨범",
                    onTap: () async {
                      // 앨범 열기 기능
                      var result = await PhotoManager.requestPermissionExtend();

                      if (result == PermissionState.authorized || result == PermissionState.limited) {
                        setState(() {
                          _isAlbumOpen = true;
                        });
                      } else {
                        PhotoManager.openSetting();
                      }
                    },
                  ),
                  _buildBottomSheetItem(
                    icon: Icons.attach_file,
                    backgroundColor: Colors.black54,
                    label: "파일 전송",
                    onTap: () {
                      // 파일 전송 기능
                    },
                  ),
                ],
              ),
            ) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetItem(
      {required IconData icon, required Color backgroundColor, required String label, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: backgroundColor,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ],
    );
  }
}