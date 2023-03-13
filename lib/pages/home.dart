import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:provider/provider.dart';
import 'package:safego/model/api/fetch.dart';
import 'package:safego/model/authentication/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? newsTitle;
  var ctime;
  final int _selectedIndex = 0;
  final AuthRepository _authRepository = AuthRepository();

  final successSnackBar = SnackBar(
    content: I18nText("home.loginSuccess"),
  );

  void _onItemTapped(int index) async {
    debugPrint("$_selectedIndex");
    await changePage(index);
  }

  changePage(index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/weather');
        break;
      case 2:
        Navigator.pushNamed(context, '/attractions');
        break;
      case 3:
        if (Provider.of<Member>(context, listen: false).login) {
          Navigator.pushReplacementNamed(context, '/member');
        } else {
          final loginSnackBar = SnackBar(
            content: I18nText("home.loginFirst"),
            action: SnackBarAction(
              label: '登入',
              textColor: Colors.yellow,
              onPressed: () async {
                Member.isLogin = await _authRepository.signInWithGoogle();
                if (Member.isLogin) {
                  ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
                }
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(loginSnackBar);
        }

        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await FetchTrafficNews().news();
    await FetchRoadNews().roadNews();
    setState(() {
      newsTitle =
          Provider.of<FetchTrafficNews>(context, listen: false).firstNews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (ctime == null ||
              now.difference(ctime) > const Duration(seconds: 2)) {
            ctime = now;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: I18nText("home.exitApp")));
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey,
                // child: Image.asset(''),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () =>
                              Navigator.pushNamed(context, '/roadplan'),
                          child: Ink(
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              color: Colors.grey,
                            ),
                            child: Center(
                              child: I18nText("home.routePlanning"),
                            ),
                          )),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      child: InkWell(
                        // onTap: () => debugPrint("進入肇事熱點"),
                        onTap: () {
                          FetchTrafficNews().news();
                        },
                        splashColor: Colors.blue,
                        child: Ink(
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: I18nText("home.causeTrouble"),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/feedBack'),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        splashColor: Colors.blue,
                        child: Ink(
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: I18nText("home.feedback"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: I18nText(
                      "home.trafficNews",
                      child: const Text(
                        "",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/trafficnews'),
                    child: I18nText("home.more"),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    border: Border.all(width: 0.3),
                  ),
                  width: 500,
                  height: 50,
                  child: Center(
                    child: Text(
                      newsTitle ?? "",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: I18nText(
                  "home.roadNews",
                  child: const Text(
                    "",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 500,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        alignment: Alignment(-.2, 0),
                        image: NetworkImage('https://i.imgur.com/ojaOQFi.jpg'),
                        fit: BoxFit.cover),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.grey.withOpacity(0.7),
                    height: 40,
                    width: double.infinity,
                    child: Center(
                      child: Text("燈會期間車多請盡量搭乘大眾運輸",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny),
            label: '天氣預報',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.park),
            label: '友善景點',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: '會員專區',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
