import 'package:flutter/material.dart';
import 'package:flutter_kakao_login_example/screens/kakao_login_screen.dart';
import 'package:flutter_kakao_login_example/widgets/login_button.dart';
import 'package:kakao_flutter_sdk/all.dart';

class OnlyKakaoLogin extends StatefulWidget {
  const OnlyKakaoLogin({Key? key}) : super(key: key);

  @override
  _OnlyKakaoLoginState createState() => _OnlyKakaoLoginState();
}

class _OnlyKakaoLoginState extends State<OnlyKakaoLogin> {
  bool _isKakaoTalkInstalled = false;

  var validateToken;

  @override
  void initState() {
    super.initState();
    initKakaoTalkInstalled();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => loginWithKakao(), //_isKakaoTalkInstalled ? loginWithTalk() : loginWithKakao(),
        child: loginButton(
            context,
            'assets/images/kakao_icon.png',
            'Only Kakao login',
            Colors.black87,
            Colors.yellow.withOpacity(0.7),
            Colors.yellow));
  }

  _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      validateToken = await AccessTokenStore.instance.fromStore();

      if (validateToken.refreshToken == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KakaoLoginScreen(), // 로그인 화면으로 다시 가야 함
            ));
      } else {
        /// 카카오 로그인 성공시 사용자 정보 print
        User kakaoUser = await UserApi.instance.me();

        print('> kakao id : ${kakaoUser.id.toString()}');
        print('> nickname : ${kakaoUser.properties!['nickname']}');
        print('> thumbnail_image : ${kakaoUser.properties!['thumbnail_image']}');

      }
    } catch (e) {
      print(e.toString());
    }
  }

  loginWithKakao() async {
    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }

  loginWithTalk() async {
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }

  initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao Install : ' + installed.toString());

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }
}
