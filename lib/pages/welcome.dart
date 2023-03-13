import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: SizedBox()),
          Container(
            child: Text("安全帶著走"),
          ),
          Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ButtonTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.00),
              ),
              minWidth: 350.0,
              height: 40.0,
              child: RaisedButton(
                  onPressed: () => Navigator.popAndPushNamed(context, '/home'),
                  textColor: const Color(0xFF000000),
                  color: const Color(0xFF8ABCF1),
                  child: const Text(
                    '開始使用',
                  )),
            ),
          ],)
        ],
      ),
    );
  }
}
