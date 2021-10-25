import 'package:flutter/material.dart';
import 'package:flutter_kakao_login_example/screens/kakao_login_with_firebase_auto_login.dart';
import 'package:flutter_kakao_login_example/screens/only_kakao_login.dart';

class KakaoLoginScreen extends StatefulWidget {
  const KakaoLoginScreen({Key? key}) : super(key: key);

  @override
  _KakaoLoginScreenState createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends State<KakaoLoginScreen> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              /// 단순 카카오 로그인 (웹뷰)
              OnlyKakaoLogin(),

              SizedBox(height: 10),

              /// Firebase 정보저장 및 자동로그인이 적용된 카카오 로그인 (웹뷰)
              KakaoLoginWithFirebaseAutoLogin(),
            ],
          ),
        )
      )
    );
  }
}
