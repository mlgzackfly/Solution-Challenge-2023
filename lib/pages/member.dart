import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:safego/model/api/fetch.dart';
import 'package:safego/model/authentication/auth.dart';
import 'package:safego/theme/theme.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  static List<String> language = <String>["Chinese", "English"];
  String languageValue = language.first;
  final AuthRepository _authRepository = AuthRepository();
  String? username;
  String? email;
  String? photoURL;

  void auth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
        print(user.providerData);
        for (final providerProfile in user.providerData) {
          print("provider = ${providerProfile.providerId}");
          print("uid = ${providerProfile.uid}");
          print("name = ${providerProfile.displayName}");
          print("phone = ${providerProfile.phoneNumber}");
          print("emailAddress = ${providerProfile.email}");
          print("profilePhoto = ${providerProfile.photoURL}");
          if (!mounted) return;
          setState(() {
            username = providerProfile.displayName;
            email = providerProfile.email;
            photoURL = providerProfile.photoURL;
          });
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _changeLanguage(String? value) async {
    if (value == "Chinese") {
      Lang().changeLang("zh_TW");
      Lang.userLang = value!;
      setState(() {});
      await FlutterI18n.refresh(context, const Locale("zh_TW"));
      print("選擇了 $value");
    } else if (value == "English") {
      Lang().changeLang("en_US");
      Lang.userLang = value!;
      setState(() {});
      await FlutterI18n.refresh(context, const Locale("en_US"));
      print("選擇了 $value");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, "/home");
          return Future.value(true);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: I18nText(
                  "member.title",
                  child: const Text(
                    "",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            (photoURL == null) ? null : NetworkImage(photoURL!),
                        radius: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$username",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "$email",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    I18nText("member.language"),
                    DropdownButton<String>(
                      value: Lang.userLang,
                      elevation: 16,
                      onChanged: (String? value) => _changeLanguage(value),
                      items: language
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                height: 500,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ButtonTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.00),
                  ),
                  minWidth: 100.0,
                  height: 40.0,
                  child: RaisedButton(
                    elevation: 8,
                    onPressed: () async {
                      Member.isLogin = false;
                      await _authRepository.signOut();
                      if (Member.isLogin == false) {
                        Navigator.of(context).pop();
                      }
                    },
                    textColor: const Color(0xFF65542B),
                    color: const Color(0xFFFCEECB),
                    child: I18nText(
                      "member.logout",
                      child: const Text(""),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
