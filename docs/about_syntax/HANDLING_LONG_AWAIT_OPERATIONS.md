# 處理長時間 await 操作的應對方式

## 🎯 問題情境

當 `await` 操作耗時過長時，會導致：
- 用戶體驗不佳（界面無回應）
- 應用程式看起來卡住
- 網路問題無法及時處理
- 用戶無法取消操作

## 📊 應對策略總覽

| 策略 | 適用場景 | 實作難度 | 效果 |
|------|---------|---------|------|
| **1. Loading 狀態** | 所有異步操作 | ⭐ 簡單 | ✅ 基本反饋 |
| **2. 超時處理** | 網路請求 | ⭐⭐ 中等 | ✅✅ 避免無限等待 |
| **3. 取消操作** | 用戶可取消的操作 | ⭐⭐⭐ 較難 | ✅✅✅ 最佳體驗 |
| **4. 進度指示** | 檔案上傳/下載 | ⭐⭐ 中等 | ✅✅ 詳細反饋 |
| **5. 重試機制** | 網路不穩定 | ⭐⭐ 中等 | ✅✅ 提高成功率 |
| **6. 樂觀更新** | UI 更新 | ⭐⭐⭐ 較難 | ✅✅✅ 感覺快速 |

---

## 方案 1: Loading 狀態顯示 ✅ (已實作)

### 目前實作

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  setState(() {
    _isLoading = true;                    // ✅ 顯示 Loading
    _statusMessage = '正在處理登入...';
  });

  try {
    await Supabase.instance.client.auth.signInWithIdToken(...);
    // ...
  } finally {
    setState(() {
      _isLoading = false;                 // ✅ 隱藏 Loading
    });
  }
}
```

### 優化建議：使用 finally 確保狀態重置

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  setState(() {
    _isLoading = true;
    _statusMessage = '正在處理登入...';
  });

  try {
    await Supabase.instance.client.auth.signInWithIdToken(...);
    // 成功處理...
  } catch (e) {
    // 錯誤處理...
  } finally {
    // ✅ 確保無論成功或失敗都會重置 Loading 狀態
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

---

## 方案 2: 超時處理 ⏱️

### 使用 `timeout()` 方法

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  setState(() {
    _isLoading = true;
    _statusMessage = '正在處理登入...';
  });

  try {
    // ✅ 設置 30 秒超時
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          '登入請求超時，請檢查網路連線後重試',
          const Duration(seconds: 30),
        );
      },
    );

    // 成功處理...
  } on TimeoutException catch (e) {
    // ✅ 專門處理超時錯誤
    setState(() {
      _statusMessage = '登入超時，請檢查網路連線';
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登入超時：${e.message}'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '重試',
            onPressed: () => _signIn(), // 重新嘗試登入
          ),
        ),
      );
    }
  } catch (e) {
    // 其他錯誤處理...
  }
}
```

### 進階：可配置的超時時間

```dart
class SignInConfig {
  static const Duration signInTimeout = Duration(seconds: 30);
  static const Duration networkTimeout = Duration(seconds: 10);
}

Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  try {
    await Supabase.instance.client.auth.signInWithIdToken(...)
        .timeout(SignInConfig.signInTimeout);
  } on TimeoutException {
    // 處理超時...
  }
}
```

---

## 方案 3: 取消操作 🚫

### 使用 `CancelToken` (如果 Supabase 支援)

```dart
import 'dart:async';

class _MemberProfilePageState extends State<MemberProfilePage> {
  CancelToken? _cancelToken;

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    // ✅ 創建取消令牌
    _cancelToken = CancelToken();
    
    setState(() {
      _isLoading = true;
      _statusMessage = '正在處理登入...';
    });

    try {
      // 注意：Supabase 可能不直接支援 CancelToken
      // 這是一個概念性範例
      await _signInWithCancel(_cancelToken!);
      
      // 成功處理...
    } on CancelException {
      // ✅ 用戶取消操作
      if (mounted) {
        setState(() {
          _statusMessage = '登入已取消';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 其他錯誤...
    }
  }

  // 取消操作的方法
  void _cancelSignIn() {
    _cancelToken?.cancel('用戶取消登入');
    setState(() {
      _isLoading = false;
      _statusMessage = '登入已取消';
    });
  }
}
```

### 實際可用的取消方式：使用 `Completer`

```dart
class _MemberProfilePageState extends State<MemberProfilePage> {
  Completer<void>? _signInCompleter;
  bool _isCancelled = false;

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    _signInCompleter = Completer<void>();
    _isCancelled = false;

    setState(() {
      _isLoading = true;
      _statusMessage = '正在處理登入...';
    });

    try {
      // 執行登入操作
      final signInFuture = Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      // ✅ 使用 Future.any 實現可取消
      await Future.any([
        signInFuture,
        _signInCompleter!.future, // 如果完成，表示取消
      ]);

      if (_isCancelled) {
        return; // 已取消，直接返回
      }

      // 成功處理...
    } catch (e) {
      if (!_isCancelled && mounted) {
        // 錯誤處理...
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelSignIn() {
    _isCancelled = true;
    _signInCompleter?.complete();
  }

  @override
  void dispose() {
    _cancelSignIn(); // 清理時取消操作
    super.dispose();
  }
}
```

---

## 方案 4: 進度指示 📊

### 使用 `Stream` 顯示進度

```dart
class _MemberProfilePageState extends State<MemberProfilePage> {
  double _progress = 0.0;

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _statusMessage = '正在處理登入...';
    });

    try {
      // 模擬進度更新
      await _signInWithProgress(idToken);
      
      // 成功處理...
    } catch (e) {
      // 錯誤處理...
    }
  }

  Future<void> _signInWithProgress(String idToken) async {
    // 階段 1: 準備請求 (0-30%)
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _progress = 0.3;
        _statusMessage = '正在連接伺服器...';
      });
    }

    // 階段 2: 發送請求 (30-60%)
    final signInFuture = Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    // 使用 timeout 避免無限等待
    await signInFuture.timeout(const Duration(seconds: 20));

    if (mounted) {
      setState(() {
        _progress = 0.6;
        _statusMessage = '正在驗證身份...';
      });
    }

    // 階段 3: 處理回應 (60-100%)
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _progress = 1.0;
        _statusMessage = '登入成功！';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ 顯示進度條
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          // ... 其他 UI
        ],
      ),
    );
  }
}
```

---

## 方案 5: 重試機制 🔄

### 自動重試機制

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  setState(() {
    _isLoading = true;
    _statusMessage = '正在處理登入...';
  });

  const maxRetries = 3;
  const retryDelay = Duration(seconds: 2);
  
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      // ✅ 嘗試登入
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      ).timeout(const Duration(seconds: 15));

      // 成功，跳出循環
      _handleSignInSuccess();
      return;

    } on TimeoutException {
      if (attempt < maxRetries) {
        // ✅ 還有重試機會
        setState(() {
          _statusMessage = '連線超時，正在重試 ($attempt/$maxRetries)...';
        });
        
        await Future.delayed(retryDelay * attempt); // 指數退避
        continue;
      } else {
        // ✅ 達到最大重試次數
        throw TimeoutException('登入失敗：已重試 $maxRetries 次仍無法連線');
      }
    } catch (e) {
      // 其他錯誤不重試
      rethrow;
    }
  }
}
```

### 智能重試（根據錯誤類型決定）

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  const maxRetries = 3;
  
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await Supabase.instance.client.auth.signInWithIdToken(...);
      _handleSignInSuccess();
      return;
      
    } on TimeoutException catch (e) {
      // ✅ 超時錯誤：可以重試
      if (attempt < maxRetries) {
        await _retryWithDelay(attempt);
        continue;
      }
      rethrow;
      
    } on AuthException catch (e) {
      // ✅ 認證錯誤：可能是 token 問題，不重試
      throw e;
      
    } on SocketException catch (e) {
      // ✅ 網路錯誤：可以重試
      if (attempt < maxRetries) {
        await _retryWithDelay(attempt);
        continue;
      }
      rethrow;
    }
  }
}

Future<void> _retryWithDelay(int attempt) async {
  final delay = Duration(seconds: attempt * 2); // 指數退避
  if (mounted) {
    setState(() {
      _statusMessage = '連線失敗，${delay.inSeconds} 秒後重試...';
    });
  }
  await Future.delayed(delay);
}
```

---

## 方案 6: 組合方案 🎯 (推薦)

### 完整的實作範例

```dart
Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
  // ✅ 1. Loading 狀態
  setState(() {
    _isLoading = true;
    _statusMessage = '正在處理登入...';
  });

  const maxRetries = 2;
  const timeoutDuration = Duration(seconds: 20);

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      // ✅ 2. 超時處理
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      ).timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            '登入請求超時',
            timeoutDuration,
          );
        },
      );

      // ✅ 3. 成功處理
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (mounted) {
        setState(() {
          _statusMessage = '登入成功！';
          _isLoading = false;
          // 更新用戶資訊...
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google 登入成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return; // 成功，退出

    } on TimeoutException catch (e) {
      // ✅ 4. 超時錯誤處理 + 重試
      if (attempt < maxRetries && mounted) {
        setState(() {
          _statusMessage = '連線超時，正在重試 ($attempt/$maxRetries)...';
        });
        await Future.delayed(Duration(seconds: attempt * 2));
        continue;
      }
      
      // 達到最大重試次數
      if (mounted) {
        setState(() {
          _statusMessage = '登入超時，請檢查網路連線';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登入超時：${e.message}'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: '重試',
              onPressed: () => _signIn(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e) {
      // ✅ 5. 其他錯誤處理
      if (mounted) {
        setState(() {
          _statusMessage = '登入失敗: $e';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登入失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return; // 其他錯誤不重試
    }
  }
}
```

---

## 📋 最佳實踐檢查清單

- ✅ **顯示 Loading 狀態** - 讓用戶知道操作正在進行
- ✅ **設置超時時間** - 避免無限等待
- ✅ **錯誤處理** - 捕獲並顯示友好的錯誤訊息
- ✅ **重試機制** - 網路問題時自動重試
- ✅ **取消操作** - 允許用戶取消長時間操作
- ✅ **進度反饋** - 顯示操作進度（如果可能）
- ✅ **mounted 檢查** - 確保 Widget 仍在 Tree 中
- ✅ **使用 finally** - 確保狀態正確重置

---

## 🎯 針對你的專案的建議

### 建議修改 `_handleGoogleSignIn` 方法

```dart
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

    // ✅ 添加超時處理（30 秒）
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          '登入請求超時，請檢查網路連線後重試',
          const Duration(seconds: 30),
        );
      },
    );

    // 更新 UI 顯示成功訊息
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (mounted) {
      setState(() {
        _statusMessage = 'Google Sign-In successful!';
        _userEmail = currentUser?.email;
        // ... 其他狀態更新
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google 登入成功！'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

  } on TimeoutException catch (e) {
    // ✅ 專門處理超時
    if (mounted) {
      setState(() {
        _statusMessage = '登入超時，請檢查網路連線';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登入超時：${e.message}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '重試',
            onPressed: () => _signIn(),
          ),
        ),
      );
    }
  } catch (e) {
    // 其他錯誤處理
    if (mounted) {
      setState(() {
        _statusMessage = 'Error during Google Sign-In: $e';
        _isLoading = false;
      });

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
```

---

## 🔗 相關資源

- [Dart Future.timeout 文檔](https://api.dart.dev/stable/dart-async/Future/timeout.html)
- [Flutter 異步操作最佳實踐](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [錯誤處理指南](https://dart.dev/guides/libraries/futures-error-handling)
