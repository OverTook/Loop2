import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_auth;

import 'chat.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<kakao_auth.OAuthToken?> loginKakao() async {
    try {
      kakao_auth.OAuthToken token = await kakao_auth.UserApi.instance.loginWithKakaoTalk();
      return token;
    } catch (error) {
      debugPrint('카카오톡으로 로그인 실패 $error');
      return null;
    }
  }

  Future<bool> loginFirebase(kakao_auth.OAuthToken token) async {
    try {
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(
          firebase_auth.OAuthProvider('oidc.kakao_login').credential(
            idToken: token.idToken,
            accessToken: token.accessToken,
          )
      );
      return true;
    } catch (error) {
      debugPrint('로그인 실패 $error');
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, // 네비게이션 바의 배경색
          systemNavigationBarDividerColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
          statusBarColor: Colors.transparent, // 상태 바의 배경색
          statusBarIconBrightness: Brightness.dark, // 상태 바 아이콘 색상
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/loop_logo.png', width: 300, height: 300),
                const Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '공무 처리 지원 서비스',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 55, 182, 255),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              ],
            ),

            // 화면 하단에 버튼
            const Spacer(),
            InkWell(
              onTap: () async {
                // 버튼 누르면 스낵바 표시
                kakao_auth.OAuthToken? token = await loginKakao();
                if(token == null) {
                  debugPrint("카카오 로그인 실패");
                  return;
                }

                bool loginResult = await loginFirebase(token);
                if(!loginResult) {
                  debugPrint("Firebase 로그인 실패");
                  return;
                }

                if(!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              splashColor: Colors.black.withOpacity(0.2), // 클릭할 때의 물결색
              borderRadius: BorderRadius.circular(8), // 잔물결 효과를 위한 경계 곡률
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white, // 박스의 배경색
                  borderRadius: BorderRadius.circular(10.0), // 모서리를 둥글게 하는 radius
                  boxShadow: [ // 그림자 추가
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Ink.image(
                  fit: BoxFit.cover, // Fixes border issues
                  width: 244,
                  height: 60,
                  image: const AssetImage(
                    'assets/images/kakao_login_large_narrow.png',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 75), // 버튼과 하단 화면 간격
          ],
        ),
      ),
    );
  }
}
