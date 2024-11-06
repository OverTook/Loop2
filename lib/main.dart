import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:loop/manager/temp_manager.dart';
import 'package:loop/screen/chat.dart';
import 'package:loop/screen/login.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  KakaoSdk.init(
    nativeAppKey: 'e7cbf47f62608a85b7c27a548c00d509',
    javaScriptAppKey: '5a672a68e51b8ae658caa536d8020854',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  TempManager().init(); //정보 임시 저장 클래스 초기화

  var appInstance = LoopApp(
      isLoggedIn: await credentialCheck()
  );

  FlutterNativeSplash.remove();

  runApp(appInstance);
}

Future<bool> credentialCheck() async {
  try {
    User user = await UserApi.instance.me();
    debugPrint('사용자 정보 요청 성공'
        '\n회원번호: ${user.id}'
        '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
        '\n이메일: ${user.kakaoAccount?.email}');

    return true;
  } catch (error) {
    return false;
  }
}

class LoopApp extends StatelessWidget {
  final bool isLoggedIn;
  const LoopApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Loop',
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
        home: isLoggedIn ? const ChatPage() : const LoginPage(),
    );
  }
}