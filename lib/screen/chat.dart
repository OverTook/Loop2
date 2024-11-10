import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:loop/manager/temp_manager.dart';

const bottomSheetAnimationTime = 200;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  final FocusNode _focusNode = FocusNode();

  DateTime currentTime = DateTime.now();
  bool canPopNow = false;

  bool reopenKeyboard = false;
  bool isKeyboardOpen = false;
  bool isSheetOpen = false;

  late AnimationController _controller;
  late double _keyboardHeight;

  void exitApp() {
    //Android iOS 구분
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _keyboardHeight = TempManager().getKeyboardHeight();
    _controller = AnimationController(
      duration: const Duration(milliseconds: bottomSheetAnimationTime),
      vsync: this,
    );

    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      setState(() {
        isKeyboardOpen = height > 1;
        if(isKeyboardOpen) {
          isSheetOpen = false;
          reopenKeyboard = false;
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
      isSheetOpen = !isSheetOpen;
      if(isKeyboardOpen && isSheetOpen) {
        isKeyboardOpen = false;
        reopenKeyboard = true;
        FocusManager.instance.primaryFocus?.unfocus();
        return;
      }

      if (isSheetOpen) {
        _controller.forward();
      } else if(!reopenKeyboard) {
        _controller.reverse();
      } else {
        isKeyboardOpen = true;
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvokedWithResult: (didPop, dynamic) {
        final now = DateTime.now();
        if(isSheetOpen) {
          reopenKeyboard = false;
          _toggleBottomSheet();
          return;
        }

        if (now.difference(currentTime) > const Duration(seconds: 2)) {
          currentTime = now;
          setState(() {
            canPopNow = false;
          });
          return;
        } else {
          setState(() {
            canPopNow = true;
          });

          exitApp();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white, // 네비게이션 바의 배경색
            systemNavigationBarDividerColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
            statusBarColor: Colors.transparent, // 상태 바의 배경색
            statusBarIconBrightness: Brightness.dark, // 상태 바 아이콘 색상
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 3.0,
          shadowColor: Colors.black.withOpacity(0.5),
          title: const Text(
            '충주시 채팅방',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // 검색 기능 구현
                // 임시로 로그아웃으로 쓴다.
                FirebaseAuth.instance.signOut();
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // 햄버거 메뉴 기능 구현
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 메인 화면 내용 (예: 채팅 메시지 목록)
            Positioned.fill(
              child: Container(color: Colors.white),
            ),

            // 하단 입력창
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: bottomSheetAnimationTime),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: isSheetOpen || isKeyboardOpen ? _keyboardHeight : 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _toggleBottomSheet,
                        child: AnimatedRotation(
                          turns: isSheetOpen ? 0.125 : 0, // 45도 회전
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
                duration: const Duration(milliseconds: bottomSheetAnimationTime),
                curve: Curves.easeOutCubic,
                height: isSheetOpen || isKeyboardOpen ? _keyboardHeight : 0,
                color: Colors.grey[200],
                child: isSheetOpen ? const Center(child: Text('Bottom Sheet Content')) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

}