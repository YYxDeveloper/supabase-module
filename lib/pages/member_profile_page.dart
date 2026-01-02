import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  String? _statusMessage;
  String? _userEmail;
  String? _userId;
  String? _userName;
  String? _userAvatarUrl;
  String? _userPhone;
  String? _userCreatedAt;
  String? _userLastSignInAt;
  Map<String, dynamic>? _userMetadata;
  bool _isLoading = false;
  bool _isAppleSignInLoading = false;

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
        _userId = user.id;
        _userName =
            user.userMetadata?['name'] ?? user.userMetadata?['full_name'];
        _userAvatarUrl =
            user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
        _userPhone = user.phone;
        _userCreatedAt = user.createdAt;
        _userLastSignInAt = user.lastSignInAt;
        _userMetadata = user.userMetadata;
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
      final currentUser = Supabase.instance.client.auth.currentUser;
      setState(() {
        _statusMessage = 'Google Sign-In successful!';
        _userEmail = currentUser?.email;
        _userId = currentUser?.id;
        _userName =
            currentUser?.userMetadata?['name'] ??
            currentUser?.userMetadata?['full_name'] ??
            currentUser?.userMetadata?['email'];
        _userAvatarUrl =
            currentUser?.userMetadata?['avatar_url'] ??
            currentUser?.userMetadata?['picture'];
        _userPhone = currentUser?.phone;
        _userCreatedAt = currentUser?.createdAt;
        _userLastSignInAt = currentUser?.lastSignInAt;
        _userMetadata = currentUser?.userMetadata;
        _isLoading = false;
      });

      // 顯示成功 SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google 登入成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 12),
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
            duration: const Duration(seconds: 13),
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
      developer.log('開始 Google Sign-In 流程', name: 'GoogleSignIn');

      // 使用 authenticate() 方法進行登入
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email', 'profile']);

      developer.log('Google Sign-In authenticate() 成功', name: 'GoogleSignIn');

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
          if (errorString.contains('reauth failed') ||
              errorString.contains('Account reauth failed')) {
            developer.log(
              '檢測到 Account reauth failed - 可能是 SHA-1 憑證指紋設定問題',
              name: 'GoogleSignIn',
            );
            errorMessage =
                '驗證失敗：請確認 SHA-1 憑證指紋 (3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93) 已正確設定在 Google Cloud Console';
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
          } else if (errorString.contains('network') ||
              errorString.contains('網路')) {
            errorMessage = '網路錯誤，請檢查網路連線';
          } else if (errorString.contains('reauth failed') ||
              errorString.contains('驗證失敗') ||
              errorString.contains('Account reauth failed')) {
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

  Future<void> _signInWithApple() async {
    // Apple Sign-In 僅在 iOS 和 macOS 上可用
    if (!Platform.isIOS && !Platform.isMacOS) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign-In 僅在 iOS 和 macOS 上可用'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isAppleSignInLoading = true;
      _statusMessage = '正在啟動 Apple 登入...';
    });

    try {
      developer.log('開始 Apple Sign-In 流程', name: 'AppleSignIn');

      // 使用 sign_in_with_apple 套件進行 Apple 登入
      //
      // 注意：sign_in_with_apple 套件在 iOS 上預設使用 Bundle ID 作為 ID token 的 audience
      // Bundle ID: com.example.subabasePark
      //
      // 重要：Supabase Dashboard 中的 Services ID 必須與 Bundle ID 一致
      // 如果 Supabase 設定的是 Services ID (com.example.subabasePark.auth)，
      // 請在 Supabase Dashboard 中將 Services ID 改為 Bundle ID (com.example.subabasePark)
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      developer.log('Apple Sign-In 認證成功，取得 credential', name: 'AppleSignIn');

      // 檢查是否有 ID Token
      if (credential.identityToken == null) {
        throw '無法取得 Apple ID Token';
      }

      // 使用 Supabase 進行登入
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      developer.log('Supabase Apple Sign-In 成功', name: 'AppleSignIn');

      // 更新 UI 顯示成功訊息
      final currentUser = Supabase.instance.client.auth.currentUser;
      setState(() {
        _statusMessage = 'Apple Sign-In 成功！';
        _userEmail = currentUser?.email ?? credential.email;
        _userId = currentUser?.id;
        // Apple 可能不會提供姓名，使用 credential 中的資訊
        _userName =
            credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : currentUser?.userMetadata?['full_name'] ??
                  currentUser?.userMetadata?['name'] ??
                  credential.email;
        _userAvatarUrl = currentUser?.userMetadata?['avatar_url'];
        _userPhone = currentUser?.phone;
        _userCreatedAt = currentUser?.createdAt;
        _userLastSignInAt = currentUser?.lastSignInAt;
        _userMetadata = currentUser?.userMetadata;
        _isAppleSignInLoading = false;
      });

      // 顯示成功 SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple 登入成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on SignInWithAppleAuthorizationException catch (e, stackTrace) {
      developer.log(
        'Apple Sign-In 授權錯誤',
        name: 'AppleSignIn',
        error: e,
        stackTrace: stackTrace,
      );

      String errorMessage = 'Apple 登入失敗';
      Color backgroundColor = Colors.red;

      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          errorMessage = '登入已取消';
          backgroundColor = Colors.orange;
          break;
        case AuthorizationErrorCode.failed:
          errorMessage = '登入失敗：${e.message ?? "未知錯誤"}';
          break;
        case AuthorizationErrorCode.invalidResponse:
          errorMessage = '無效的回應：${e.message ?? "未知錯誤"}';
          break;
        case AuthorizationErrorCode.notHandled:
          errorMessage = '無法處理登入請求：${e.message ?? "未知錯誤"}';
          break;
        case AuthorizationErrorCode.notInteractive:
          errorMessage = '登入請求無法以互動方式完成：${e.message ?? "未知錯誤"}';
          break;
        case AuthorizationErrorCode.unknown:
          errorMessage = '未知錯誤：${e.message ?? "未知錯誤"}';
          break;
      }

      setState(() {
        _isAppleSignInLoading = false;
        _statusMessage = errorMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Apple Sign-In 未預期的錯誤',
        name: 'AppleSignIn',
        error: e,
        stackTrace: stackTrace,
      );

      setState(() {
        _isAppleSignInLoading = false;
        _statusMessage = 'Apple 登入失敗: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple 登入失敗: $e'),
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
        _userId = null;
        _userName = null;
        _userAvatarUrl = null;
        _userPhone = null;
        _userCreatedAt = null;
        _userLastSignInAt = null;
        _userMetadata = null;
        _isAppleSignInLoading = false;
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
        title: const Text('會員資料'),
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
                // 用戶頭像
                if (_userAvatarUrl != null)
                  ClipOval(
                    child: Image.network(
                      _userAvatarUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.green,
                        );
                      },
                    ),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  '已登入',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 用戶資訊卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_userName != null) ...[
                        _buildInfoRow('姓名', _userName!),
                        const SizedBox(height: 12),
                      ],
                      if (_userEmail != null) ...[
                        _buildInfoRow('電子郵件', _userEmail!),
                        const SizedBox(height: 12),
                      ],
                      if (_userId != null) ...[
                        _buildInfoRow('用戶 ID', _userId!),
                        const SizedBox(height: 12),
                      ],
                      if (_userPhone != null) ...[
                        _buildInfoRow('電話', _userPhone!),
                        const SizedBox(height: 12),
                      ],
                      if (_userCreatedAt != null) ...[
                        _buildInfoRow(
                          '建立時間',
                          _formatDateTimeString(_userCreatedAt!),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_userLastSignInAt != null) ...[
                        _buildInfoRow(
                          '最後登入',
                          _formatDateTimeString(_userLastSignInAt!),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_userMetadata != null &&
                          _userMetadata!.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          '其他資訊',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._userMetadata!.entries.map((entry) {
                          if (entry.value != null &&
                              entry.key != 'name' &&
                              entry.key != 'full_name' &&
                              entry.key != 'avatar_url' &&
                              entry.key != 'picture' &&
                              entry.key != 'email') {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildInfoRow(
                                entry.key,
                                entry.value.toString(),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const Icon(Icons.account_circle, size: 64, color: Colors.grey),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '狀態',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _userEmail != null
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _userEmail != null
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
              ElevatedButton.icon(
                onPressed: (_isLoading || _isAppleSignInLoading)
                    ? null
                    : _signIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (_isLoading || _isAppleSignInLoading)
                    ? null
                    : _signInWithApple,
                icon: _isAppleSignInLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.apple, color: Colors.white),
                label: Text(
                  _isAppleSignInLoading ? '處理中...' : 'Sign in with Apple',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTimeString(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      // 如果解析失敗，返回原始字串
      return dateTimeString;
    }
  }
}




