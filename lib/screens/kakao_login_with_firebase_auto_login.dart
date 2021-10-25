import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao_login_example/screens/kakao_login_screen.dart';
import 'package:flutter_kakao_login_example/widgets/login_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import '../main.dart';
import '../models/current_user.dart';

class KakaoLoginWithFirebaseAutoLogin extends StatefulWidget {
  const KakaoLoginWithFirebaseAutoLogin({Key? key}) : super(key: key);

  @override
  _KakaoLoginWithFirebaseAutoLoginState createState() => _KakaoLoginWithFirebaseAutoLoginState();
}

class _KakaoLoginWithFirebaseAutoLoginState extends State<KakaoLoginWithFirebaseAutoLogin> {
  bool _isKakaoTalkInstalled = false;

  late DocumentSnapshot documentSnapshot;
  var validateToken;
  var userReference = FirebaseFirestore.instance.collection('Users');

  @override
  void initState() {
    super.initState();
    initKakaoTalkInstalled();
    /// 자동 로그인 체크
    checkLoggedInKakaoState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => loginWithKakao(), // _isKakaoTalkInstalled ? loginWithTalk() : loginWithKakao(),
        child: loginButton(
            context,
            'assets/images/kakao_icon.png',
            'Kakao login with\nfirebase & auto login',
            Colors.black87,
            Colors.yellow.withOpacity(0.7),
            Colors.yellow));
  }

  initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao Install : ' + installed.toString());

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  // for kakao auth login
  void checkLoggedInKakaoState() async {
    /// 저장해둔 카카오로그인 아이디가 있는지 체크
    final kakaoUserUid = await FlutterSecureStorage().read(key: "kakaoUserUid");

    /// 저장해둔 아이디가 있다면
    if (kakaoUserUid != null) {
      /// 해당 DB정보 가져오기
      DocumentSnapshot documentSnapshot =
      await userReference.doc(kakaoUserUid).get();

      /// 현재 유저정보에 값 셋팅하기
      setState(() {
        currentUser = CurrentUser.fromDocument(documentSnapshot);
      });

      /// HomeScreen 으로 접속하며 자동로그인 마무리
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(), // 홈화면으로 정상 로그인
          ));
    }
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
              // builder: (context) => HomePage(0),
              builder: (context) => const KakaoLoginScreen(), // 로그인 화면으로 다시 가야 함
            ));
      } else {
        /// 카카오 로그인 성공시 사용자 정보 저장하는 로직 추가해야 함
        User kakaoUser = await UserApi.instance.me();

        /// Firebase에 사용자 정보 저장되어 있는지 체크
        DocumentSnapshot documentSnapshot =
            await userReference.doc(kakaoUser.id.toString()).get();

        /// 기존에 저장된 사용자 정보가 있다면 skip, 없다면 저장해야 한다.
        if (!documentSnapshot.exists) {
          // 처음 접속하는 사용자라면 정보 저장
          // 유저정보 셋팅된 값으로 db에 set
          await userReference.doc(kakaoUser.id.toString()).set({
            'name': kakaoUser.properties!['nickname'],
            'image': kakaoUser.properties!['thumbnail_image'],
            'uid': kakaoUser.id.toString(),
            'loginType': "Kakao",
            'loggedInAt': DateTime.now(),
          });
        } else {
          await userReference
              .doc(kakaoUser.id.toString())
              .update({'loginType': "Kakao", 'loggedInAt': DateTime.now()});
        }

        /// Store user ID
        await const FlutterSecureStorage()
            .write(key: "kakaoUserUid", value: kakaoUser.id.toString());
        await const FlutterSecureStorage().write(key: "loginType", value: 'Kakao');

        /// 해당 정보 다시 가져오기
        documentSnapshot =
            await userReference.doc(kakaoUser.id.toString()).get();

        /// 현재 유저정보에 값 셋팅하기
        setState(() {
          currentUser = CurrentUser.fromDocument(documentSnapshot);
        });
      }

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(), // 홈화면으로 정상 로그인
          ));
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
}
