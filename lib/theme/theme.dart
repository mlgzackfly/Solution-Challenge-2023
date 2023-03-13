import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: 'NotoSansCJKtc-Medium',
);

class Lang with ChangeNotifier{
  static String userLang = "Chinese";
  static String appLang = "zh_TW";
  changeLang(String lang) {
    appLang = lang;
    notifyListeners();
  }

  static FlutterI18nDelegate i18n = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: true,
      basePath: "assets/i18n",
      // fallbackFile: "zh_TW.json",
      forcedLocale: Locale(appLang),
    ),
    missingTranslationHandler: (key, locale) {
      print("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
    },
  );
}
