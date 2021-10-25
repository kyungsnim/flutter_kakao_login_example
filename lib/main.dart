import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'screens/kakao_login_screen.dart';
import 'models/current_user.dart';

Future<void> main() async {
  /// Firebase 사용을 위한 셋팅
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  /// Firebase 사용을 위한 셋팅

  /// 카카오 로그인 사용을 위한 셋팅
  KakaoContext.clientId = "723ef78e0cb96ce5f95a3f8c056dc127";

  runApp(const MyApp());
}

/// 어디서든 사용자 정보를 조회할 수 있도록 전역변수로 선언
CurrentUser? currentUser;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KakaoLoginScreen(),
    );
  }
}