import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loop/screen/chat/bottom_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          const BottomInputWidget(),
        ],
      ),
    );
  }
}