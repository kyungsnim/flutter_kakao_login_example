import 'package:flutter/material.dart';
import 'package:flutter_kakao_login_example/screens/kakao_login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/all.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: currentUser == null ? const CircularProgressIndicator() : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('uid : ${currentUser!.uid}'),
          Text('name : ${currentUser!.name}'),
          Image.network(currentUser!.image),
          const SizedBox(height: 10),
          TextButton(onPressed: () => logoutUser(), child: const Text('로그아웃'))
        ],
      )),
    );
  }

  logoutUser() async {
    try {
      /// 자동로그인정보 모두 삭제 후 로그인페이지로 이동
      await const FlutterSecureStorage().deleteAll();

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const KakaoLoginScreen())).then((_) {
        if(mounted) {
          setState(() {
            currentUser = null;
          });
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
