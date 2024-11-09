import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart' as kakao_auth;
import 'package:loop/manager/temp_manager.dart';
import 'package:loop/screen/chat.dart';
import 'package:loop/screen/login.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  kakao_auth.KakaoSdk.init(
    nativeAppKey: 'e7cbf47f62608a85b7c27a548c00d509',
    javaScriptAppKey: '5a672a68e51b8ae658caa536d8020854',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await TempManager().init(); //정보 임시 저장 클래스 초기화

  FlutterNativeSplash.remove();

  var user = firebase_auth.FirebaseAuth.instance.currentUser;
  if(user != null) {
    debugPrint("로그인");
    debugPrint(user.displayName);
    debugPrint(user.email);
    debugPrint(user.photoURL);
    debugPrint(user.phoneNumber);
    debugPrint(user.uid);
  }

  runApp(LoopApp(
      isLoggedIn: firebase_auth.FirebaseAuth.instance.currentUser != null
  ));
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
        home: isLoggedIn ? const ChatScreen() : const LoginScreen(),
    );
  }
}