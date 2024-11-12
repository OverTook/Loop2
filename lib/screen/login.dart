import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_auth;
import 'package:loop/manager/temp_manager.dart';
import 'package:loop/screen/license.dart';

import 'chat.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<bool> _login() async {
    try {
      kakao_auth.OAuthToken token = await kakao_auth.UserApi.instance.loginWithKakaoTalk();
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

  Future<String?> _getLicense() async {
    var user = firebase_auth.FirebaseAuth.instance.currentUser;
    if(user == null) {
      return null;
    }

    var claims = (await user.getIdTokenResult()).claims;
    debugPrint(claims.toString());
    if(claims == null) {
      return null;
    }

    var licenses = claims["licenses"];
    debugPrint(licenses.toString());
    debugPrint(licenses.runtimeType.toString());
    if(licenses == null) {
      return null;
    }

    if(licenses is! Map<Object?, Object?>) {
      return null;
    }

    return licenses["key"] as String?;
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
            const Spacer(),
            InkWell(
              onTap: () async {
                bool loginResult = await _login();
                if(!loginResult) {
                  debugPrint("Firebase 로그인 실패");
                  return;
                }

                var currentLicense = await _getLicense();
                if(!context.mounted) {
                  return;
                }

                debugPrint(currentLicense);
                if(TempManager().getKeyboardHeight() == 0 || currentLicense == null) {
                  //키보드 높이가 저장되지 않았으므로
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LicenseInputScreen(license: currentLicense)),
                  );
                  return;
                }


                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
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
