import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:auth_package/auth_package.dart';
import 'pages/main_navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // 初始化 Google Sign In
  // iOS: 使用 iOS Client ID（支援 custom scheme）
  // Android/Web: 使用 Web Client ID
  // serverClientId: Server Client ID（所有平台必需，用於獲取 ID Token）
  final webClientId =
      '794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com';
  final iosClientId =
      '794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com';

  if (Platform.isIOS) {
    // iOS 平台：使用 iOS Client ID（支援 custom scheme）
    // serverClientId 使用 Web Client ID 以確保 ID Token 可用於 Supabase
    await GoogleSignIn.instance.initialize(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
  } else {
    // Android 和 Web 平台：使用 Web Client ID
    await GoogleSignIn.instance.initialize(
      clientId: webClientId,
      serverClientId: webClientId,
    );
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'), // 繁體中文
        Locale('en', 'US'), // 英文
      ],
      // 根據系統語系自動選擇語言：繁體中文使用繁體中文，其他一律使用英文
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale == null) {
          return const Locale('en', 'US'); // 如果無法取得系統語系，預設使用英文
        }

        // 檢查是否為繁體中文（台灣或香港）
        if (locale.languageCode == 'zh') {
          // 台灣或香港使用繁體中文
          if (locale.countryCode == 'TW' || locale.countryCode == 'HK') {
            return const Locale('zh', 'TW');
          }
          // 其他中文變體（簡體中文等）使用英文
          return const Locale('en', 'US');
        }

        // 非繁體中文語系一律使用英文
        return const Locale('en', 'US');
      },
      home: const MainNavigationPage(),
    );
  }
}
