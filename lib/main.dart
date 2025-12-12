import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // 初始化 Google Sign In
  // iOS: 使用 iOS Client ID（支援 custom scheme）
  // Android/Web: 使用 Web Client ID
  // serverClientId: Server Client ID（所有平台必需，用於獲取 ID Token）
  final webClientId = '794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com';
  final iosClientId = '794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com';
  
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _statusMessage;
  String? _userEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 檢查是否已經登入
    _checkCurrentUser();
    // 監聽 Google Sign In 事件
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _handleGoogleSignIn(event.user);
      }
    });
  }

  void _checkCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
        _statusMessage = '已登入';
      });
    }
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在處理登入...';
    });

    try {
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      // 更新 UI 顯示成功訊息
      setState(() {
        _statusMessage = 'Google Sign-In successful!';
        _userEmail = Supabase.instance.client.auth.currentUser?.email;
        _isLoading = false;
      });

      // 顯示成功 SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google 登入成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error during Google Sign-In: $e';
        _isLoading = false;
      });

      // 顯示錯誤 SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登入失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在啟動 Google 登入...';
    });

    try {
      developer.log(
        '開始 Google Sign-In 流程',
        name: 'GoogleSignIn',
      );
      
      // 使用 authenticate() 方法進行登入
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      developer.log(
        'Google Sign-In authenticate() 成功',
        name: 'GoogleSignIn',
      );
      
      await _handleGoogleSignIn(account);
    } on GoogleSignInException catch (e, stackTrace) {
      // 記錄完整的錯誤資訊
      developer.log(
        '捕獲到 GoogleSignInException',
        name: 'GoogleSignIn',
        error: e,
        stackTrace: stackTrace,
      );
      developer.log(
        '錯誤詳情: code=${e.code}, toString=${e.toString()}',
        name: 'GoogleSignIn',
      );

      setState(() {
        _isLoading = false;
      });

      String errorMessage = '登入失敗';
      Color backgroundColor = Colors.red;

      // 根據錯誤類型提供不同的訊息
      // 注意：google_sign_in 7.2.0 只支援 canceled 和 clientConfigurationError
      final errorString = e.toString();
      
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          // 記錄登入取消的詳細原因
          developer.log(
            'Google Sign-In 登入已取消 (code: canceled)',
            name: 'GoogleSignIn',
            error: e,
            stackTrace: stackTrace,
          );
          developer.log(
            '取消原因詳情: code=${e.code}, error=$errorString',
            name: 'GoogleSignIn',
          );
          
          // 檢查是否為 reauth failed
          if (errorString.contains('reauth failed') || errorString.contains('Account reauth failed')) {
            developer.log(
              '檢測到 Account reauth failed - 可能是 SHA-1 憑證指紋設定問題',
              name: 'GoogleSignIn',
            );
            errorMessage = '驗證失敗：請確認 SHA-1 憑證指紋 (3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93) 已正確設定在 Google Cloud Console';
            backgroundColor = Colors.red;
          } else {
            errorMessage = '登入已取消';
            backgroundColor = Colors.orange;
          }
          break;
        case GoogleSignInExceptionCode.clientConfigurationError:
          developer.log(
            'Google Sign-In 設定錯誤',
            name: 'GoogleSignIn',
            error: e,
            stackTrace: stackTrace,
          );
          errorMessage = '設定錯誤：請確認 SHA-1 憑證指紋已正確設定在 Google Cloud Console';
          break;
        default:
          // 處理其他未知錯誤
          developer.log(
            '未知的 GoogleSignInException 錯誤代碼: ${e.code}',
            name: 'GoogleSignIn',
            error: e,
            stackTrace: stackTrace,
          );
          
          if (errorString.contains('canceled') || errorString.contains('取消')) {
            // 記錄登入取消的詳細原因（從錯誤字串判斷）
            developer.log(
              'Google Sign-In 登入已取消（從錯誤訊息判斷）',
              name: 'GoogleSignIn',
              error: e,
              stackTrace: stackTrace,
            );
            developer.log(
              '取消原因詳情: code=${e.code}, error=$errorString',
              name: 'GoogleSignIn',
            );
            errorMessage = '登入已取消';
            backgroundColor = Colors.orange;
          } else if (errorString.contains('network') || errorString.contains('網路')) {
            errorMessage = '網路錯誤，請檢查網路連線';
          } else if (errorString.contains('reauth failed') || errorString.contains('驗證失敗') || errorString.contains('Account reauth failed')) {
            developer.log(
              '檢測到 Account reauth failed - SHA-1 憑證指紋設定問題',
              name: 'GoogleSignIn',
            );
            errorMessage = '驗證失敗：請確認 SHA-1 憑證指紋已正確設定在 Google Cloud Console';
          } else {
            errorMessage = '登入失敗: $errorString';
          }
      }

      setState(() {
        _statusMessage = errorMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      // 捕獲所有其他類型的錯誤
      developer.log(
        '捕獲到未預期的錯誤',
        name: 'GoogleSignIn',
        error: e,
        stackTrace: stackTrace,
      );
      
      setState(() {
        _isLoading = false;
        _statusMessage = '發生未知錯誤: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登入失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await Supabase.instance.client.auth.signOut();
      setState(() {
        _statusMessage = null;
        _userEmail = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已登出'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登出失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _userEmail != null
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: '登出',
                ),
              ]
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userEmail != null) ...[
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '已登入',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'User: $_userEmail',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ] else ...[
                const Icon(
                  Icons.account_circle,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
              ],
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _userEmail != null
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _userEmail != null
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _userEmail != null
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(_isLoading ? '處理中...' : 'Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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
