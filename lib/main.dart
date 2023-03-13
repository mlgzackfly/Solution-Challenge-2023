import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:safego/model/api/fetch.dart';
import 'package:safego/model/api/directions.dart';
import 'package:safego/pages/feedback.dart';
import 'package:safego/pages/home.dart';
import 'package:safego/pages/member.dart';
import 'package:safego/pages/news.dart';
import 'package:safego/pages/roadplan.dart';
import 'package:safego/pages/trafficnews.dart';
import 'package:safego/pages/weather.dart';
import 'package:safego/pages/welcome.dart';
import 'package:safego/pages/attractions.dart';
import 'package:safego/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FetchWeather()),
        ChangeNotifierProvider.value(
          value: Member(),
        ),
        ChangeNotifierProvider.value(
          value: FetchAttrations(),
        ),
        ChangeNotifierProvider.value(
          value: FetchRoadNews(),
        ),
        ChangeNotifierProvider.value(
          value: FetchTrafficNews(),
        ),
        ChangeNotifierProvider.value(
          value: Lang(),
        ),
        ChangeNotifierProvider.value(
          value: Directions(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '安全帶著走',
        theme: appTheme,
        initialRoute: '/home',
        routes: {
          // '/': (context) => const WelcomePage(),
          '/home': (context) => const HomePage(),
          '/weather': (context) => const WeatherPage(),
          '/member': (context) => const MemberPage(),
          '/attractions': (context) => const AttractionsPage(),
          '/feedBack': (context) => const FeedBackPage(),
          '/roadplan': (context) => const RoadPlanPage(),
          '/trafficnews': (context) => const TrafficNews(),
          '/news': (context) => const News(),
        },
        builder: EasyLoading.init(),
        localizationsDelegates: [
          Lang.i18n,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
