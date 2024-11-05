import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:loop/screen/chat.dart';
import 'package:loop/screen/login.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: 'e7cbf47f62608a85b7c27a548c00d509',
    javaScriptAppKey: '5a672a68e51b8ae658caa536d8020854',
  );

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const LoopApp());
}

class LoopApp extends StatefulWidget {
  const LoopApp({super.key});

  @override
  State<StatefulWidget> createState() => _LoopAppState();
}

class _LoopAppState extends State<LoopApp> {
  late final Future<Widget> _credentialCheck;

  @override
  void initState() {
    super.initState();

    _credentialCheck = credentialCheck();
  }

  Future<Widget> credentialCheck() async {
    try {
      User user = await UserApi.instance.me();
      debugPrint('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}');

      FlutterNativeSplash.remove();
      return const ChatPage();
    } catch (error) {
      FlutterNativeSplash.remove();
      return const LoginPage();
    }
  }

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
      home: FutureBuilder<Widget>(
        future: _credentialCheck,
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ?? const LoginPage();
          }
          //ConnectionState가 done 아닌 경우에는 어차피 FlutterNativeSplash 에 의해 스플래쉬 화면으로 가려져 Widget Tree 가 구성되지 않는다.
          return const LoginPage();
        },
      )
    );
  }
}