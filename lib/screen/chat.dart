import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loop/manager/temp_manager.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  var currentTime = DateTime.now();
  bool canPopNow = false;

  bool isSheetOpen = false;
  late AnimationController _controller;
  late double _keyboardHeight;


  static const bottomSheetAnimationTime = 100;

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
    _keyboardHeight = TempManager().keyboardHeight;
    _controller = AnimationController(
      duration: const Duration(milliseconds: bottomSheetAnimationTime),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBottomSheet() {
    setState(() {
      isSheetOpen = !isSheetOpen;
      if (isSheetOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvokedWithResult: (didPop, dynamic) {
        final now = DateTime.now();
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
                padding: EdgeInsets.only(bottom: isSheetOpen ? _keyboardHeight : 0),
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
                          duration: const Duration(milliseconds: bottomSheetAnimationTime),
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
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: '메시지 입력',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
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
                height: isSheetOpen ? _keyboardHeight : 0,
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