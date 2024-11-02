import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'df17ea99e1579611972ffbb1ff069e51',
    javaScriptAppKey: '5a672a68e51b8ae658caa536d8020854',
  );

  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: MyHomePage(),
    ),
  );
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상단 부분에 이미지
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/loop_logo.png', width: 300, height: 300),
                const Positioned(
                  bottom: 60, // 이미지의 하단에서 약간 아래로 배치
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
            Spacer(),
            GestureDetector(
              onTap: () async {
                // 버튼 누르면 스낵바 표시
                try {
                  OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
                  print('카카오톡으로 로그인 성공 ${token.accessToken}');
                } catch (error) {
                  print('카카오톡으로 로그인 실패 $error');
                }
              },
              child: Image.asset('assets/images/kakao_login_large_narrow.png', width: 400, height: 60),
            ),
            const SizedBox(height: 50), // 버튼과 하단 화면 간격
          ],
        ),
      ),
    );
  }
}