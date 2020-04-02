import 'dart:ui';

typedef Future<bool> LocaleChangeCallback(Locale locale);

Locale getLocale(String unicodeLang) {
  if (null != unicodeLang) {
    var langParts = unicodeLang.split('_');
    return Locale.fromSubtags(
        languageCode: langParts[0],
        scriptCode: langParts.length == 3 ? langParts[1] : null,
        countryCode: langParts.length == 2
            ? langParts[1]
            : (langParts.length == 3 ? langParts[2] : null));
  }
  return null;
}
