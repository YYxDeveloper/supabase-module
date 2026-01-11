import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:auth_package/auth_package.dart';

void main() {
  group('語言選擇邏輯測試', () {
    testWidgets('系統語系為繁體中文（台灣）時應使用繁體中文', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'TW'),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              // 使用系統語系為繁體中文（台灣）
              return Scaffold(body: Text(localizations.loginButton));
            },
          ),
        ),
      );

      // 等待本地化加載完成
      await tester.pump();
      await tester.pump();
      
      // 驗證顯示繁體中文
      expect(find.text('登入'), findsOneWidget);
    });

    testWidgets('系統語系為繁體中文（香港）時應使用繁體中文', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'HK'),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
                if (locale == null) {
                  return const Locale('en', 'US');
                }

                if (locale.languageCode == 'zh') {
                  if (locale.countryCode == 'TW' ||
                      locale.countryCode == 'HK') {
                    return const Locale('zh', 'TW');
                  }
                  return const Locale('en', 'US');
                }

                return const Locale('en', 'US');
              },
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Scaffold(body: Text(localizations.loginButton));
            },
          ),
        ),
      );

      // 等待本地化加載完成
      await tester.pump();
      await tester.pump();
      // 驗證顯示繁體中文
      expect(find.text('登入'), findsOneWidget);
    });

    testWidgets('系統語系為簡體中文時應使用英文', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
                if (locale == null) {
                  return const Locale('en', 'US');
                }

                if (locale.languageCode == 'zh') {
                  if (locale.countryCode == 'TW' ||
                      locale.countryCode == 'HK') {
                    return const Locale('zh', 'TW');
                  }
                  return const Locale('en', 'US');
                }

                return const Locale('en', 'US');
              },
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Scaffold(body: Text(localizations.loginButton));
            },
          ),
        ),
      );

      // 等待本地化加載完成
      await tester.pump();
      await tester.pump();
      // 驗證顯示英文
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('系統語系為英文時應使用英文', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
                if (locale == null) {
                  return const Locale('en', 'US');
                }

                if (locale.languageCode == 'zh') {
                  if (locale.countryCode == 'TW' ||
                      locale.countryCode == 'HK') {
                    return const Locale('zh', 'TW');
                  }
                  return const Locale('en', 'US');
                }

                return const Locale('en', 'US');
              },
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Scaffold(body: Text(localizations.loginButton));
            },
          ),
        ),
      );

      // 等待本地化加載完成
      await tester.pump();
      await tester.pump();
      // 驗證顯示英文
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('系統語系為其他語言時應使用英文', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ja', 'JP'),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
                if (locale == null) {
                  return const Locale('en', 'US');
                }

                if (locale.languageCode == 'zh') {
                  if (locale.countryCode == 'TW' ||
                      locale.countryCode == 'HK') {
                    return const Locale('zh', 'TW');
                  }
                  return const Locale('en', 'US');
                }

                return const Locale('en', 'US');
              },
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              return Scaffold(body: Text(localizations.loginButton));
            },
          ),
        ),
      );

      // 等待本地化加載完成
      await tester.pump();
      await tester.pump();
      // 驗證顯示英文
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
