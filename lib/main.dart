import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'e7cbf47f62608a85b7c27a548c00d509',
    javaScriptAppKey: '5a672a68e51b8ae658caa536d8020854',
  );

  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(),
        primarySwatch: Colors.blue,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              allowEnterRouteSnapshotting: false,
            ),
          },
        ),
      ),
      home: const LoginPage(),
    );
  }
}


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const Spacer(),
            InkWell(
              onTap: () async {
                // 버튼 누르면 스낵바 표시
                try {
                  OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
                  print('카카오톡으로 로그인 성공 ${token.accessToken}');
                  try {
                    User user = await UserApi.instance.me();
                    print('사용자 정보 요청 성공'
                        '\n회원번호: ${user.id}'
                        '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                        '\n이메일: ${user.kakaoAccount?.email}');
                  } catch (error) {
                    print('사용자 정보 요청 실패 $error');
                  }
                } catch (error) {
                  print('카카오톡으로 로그인 실패 $error');
                }
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