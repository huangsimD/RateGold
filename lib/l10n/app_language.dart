import 'package:flutter/material.dart';

enum AppLanguage {
  en('en', 'English'),
  zh('zh', '中文'),
  ar('ar', 'العربية'),
  hi('hi', 'हिन्दी'),
  id('id', 'Bahasa Indonesia');

  const AppLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  Locale get locale => Locale(code);

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ar'),
    Locale('hi'),
    Locale('id'),
  ];

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}
