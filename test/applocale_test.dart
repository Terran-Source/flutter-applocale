import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:applocale/applocale.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      _localeDelegate = LocaleDelegate(_supportedLocales(), _defaultLocale);
    });

    test('First Test', () {
      expect(_localeDelegate.isSupported(getLocale("en")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_us")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_US")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("en_UK")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("ar")), isTrue);
      expect(_localeDelegate.isSupported(getLocale("zs")), isFalse);
    });
  });
}

Map<String, Locale> _supportedLanguages = <String, Locale>{
  "English": getLocale("en"),
  "English(USA)": getLocale("en_us"),
  "Arabic": getLocale('ar')
};
Locale _defaultLocale = getLocale("en");
LocaleDelegate _localeDelegate;
List<Locale> _supportedLocales() =>
    _supportedLanguages.entries.map((l) => l.value).toList();
