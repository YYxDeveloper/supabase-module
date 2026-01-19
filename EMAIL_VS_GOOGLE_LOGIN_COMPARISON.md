# 🔄 Email/Password 登入 vs Google 登入流程比較

根據 `AUTH_TO_ROOMS_FLOW.md`，以下是兩種登入方式的詳細流程比較。

---

## 📊 流程對照圖

### Email/Password 登入流程
```
用戶輸入 Email & Password
    ↓
點擊 Submit 按鈕
    ↓
onLogin() callback 被觸發
    ↓
auth.signInWithPassword(email, password)
    ↓
認證成功 → onAuthStateChange Stream 觸發
    ↓
SupabaseChatCore 自動載入用戶資料
    ↓
onSubmitAnimationCompleted() 被觸發
    ↓
onLoginSuccess() callback
    ↓
RoomsPage StreamBuilder 重新構建
    ↓
顯示聊天室列表
```

### Google 登入流程
```
點擊 Google 登入按鈕
    ↓
_signInWithGoogle() 被觸發
    ↓
_googleAuthHandler.signIn()
    ↓
GoogleSignIn.instance.authenticate()
    ↓
取得 Google ID Token
    ↓
completeSignInWithSupabase(provider: google, idToken)
    ↓
auth.signInWithIdToken(provider: google, idToken)
    ↓
認證成功 → onAuthStateChange Stream 觸發
    ↓
SupabaseChatCore 自動載入用戶資料
    ↓
_handleSocialAuthResult() 處理結果
    ↓
等待用戶資料載入 (500ms + 重試機制)
    ↓
顯示 SnackBar "Google 登入成功！"
    ↓
onLoginSuccess() callback
    ↓
RoomsPage StreamBuilder 重新構建
    ↓
顯示聊天室列表
```

---

## 🔍 詳細差異分析

### 1️⃣ **觸發入口點**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **觸發函數** | `onLogin()` callback | `_signInWithGoogle()` |
| **位置** | `SocialAuthFlutterLogin` widget | `SocialAuthScreen` |
| **檔案** | `social_auth_screen.dart:185-194` | `social_auth_screen.dart:112-124` |
| **參數** | `LoginData` (email, password) | 無（從 Google 帳號取得） |

**Email/Password 觸發**:
```dart
onLogin: (loginData) async {
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: loginData.name,
      password: loginData.password,
    );
  } catch (e) {
    return e.toString();
  }
  return null;  // 返回 null 表示成功
},
```

**Google 登入觸發**:
```dart
Future<void> _signInWithGoogle() async {
  _isGoogleLoading = true;
  setState(() {});
  
  final result = await _googleAuthHandler.signIn();
  await _handleSocialAuthResult(result, 'Google');
  
  _isGoogleLoading = false;
  if (mounted) setState(() {});
}
```

---

### 2️⃣ **認證 API 差異**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **Supabase API** | `auth.signInWithPassword()` | `auth.signInWithIdToken()` |
| **參數** | `email`, `password` | `provider: OAuthProvider.google`, `idToken` |
| **前置步驟** | 無（直接使用用戶輸入） | 需要先取得 Google ID Token |

**Email/Password API**:
```dart
await Supabase.instance.client.auth.signInWithPassword(
  email: loginData.name,
  password: loginData.password,
);
```

**Google API**:
```dart
// 1. 先取得 Google ID Token
final GoogleSignInAccount account = await GoogleSignIn.instance
    .authenticate(scopeHint: ['email', 'profile']);
final GoogleSignInAuthentication googleAuth = account.authentication;
final String? idToken = googleAuth.idToken;

// 2. 使用 ID Token 登入 Supabase
await Supabase.instance.client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
);
```

---

### 3️⃣ **認證流程步驟數**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **步驟數** | 2 步 | 4 步 |
| **步驟 1** | 輸入 email/password | 點擊 Google 按鈕 |
| **步驟 2** | `signInWithPassword()` | `GoogleSignIn.authenticate()` |
| **步驟 3** | - | 取得 ID Token |
| **步驟 4** | - | `signInWithIdToken()` |

**關鍵差異**: Google 登入需要額外的外部服務互動（Google OAuth），這增加了流程步驟。

---

### 4️⃣ **成功回調處理**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **回調函數** | `onSubmitAnimationCompleted()` | `_handleSocialAuthResult()` |
| **觸發時機** | 動畫完成後 | 認證結果返回後 |
| **檔案位置** | `social_auth_screen.dart:219-225` | `social_auth_screen.dart:63-109` |

**Email/Password 回調**:
```dart
onSubmitAnimationCompleted: () {
  // 直接呼叫 onLoginSuccess，無需等待
  if (widget.onLoginSuccess != null) {
    widget.onLoginSuccess!();
  } else {
    Navigator.of(context).pop();
  }
},
```

**Google 登入回調**:
```dart
Future<void> _handleSocialAuthResult(
  SocialAuthResult result,
  String providerName,
) async {
  if (!mounted) return;
  
  if (result.success) {
    // ⚠️ 關鍵差異：等待用戶資料載入
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 確保用戶資料已載入（重試機制）
    int retryCount = 0;
    while (retryCount < 10 && 
           SupabaseChatCore.instance.loggedUser == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }
    
    if (!mounted) return;
    
    // ⚠️ 關鍵差異：顯示 SnackBar
    _showSnackBarWithLog(
      context,
      '$providerName 登入成功！',
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      logLevel: 'INFO',
    );
    
    // 然後才呼叫 onLoginSuccess
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    } else {
      Navigator.of(context).pop();
    }
  } else {
    // 處理錯誤...
  }
}
```

---

### 5️⃣ **用戶資料載入等待**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **等待機制** | ❌ 無 | ✅ 有（500ms + 重試） |
| **等待原因** | `onSubmitAnimationCompleted` 發生在動畫後，用戶資料可能已載入 | 需要確保 `SupabaseChatCore.instance.loggedUser` 已載入 |
| **檔案位置** | 無 | `social_auth_screen.dart:70-79` |

**關鍵差異**: 
- **Email/Password**: 依賴 `SocialAuthFlutterLogin` 的成功動畫延遲，可能在動畫期間用戶資料已經載入
- **Google**: 主動等待並重試，確保用戶資料已載入才繼續

---

### 6️⃣ **錯誤處理**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **錯誤返回** | 返回 `String` 錯誤訊息 | 返回 `SocialAuthResult` 物件 |
| **錯誤顯示** | 由 `SocialAuthFlutterLogin` 自動顯示 | 手動呼叫 `_showSnackBarWithLog()` |
| **錯誤類型** | Supabase 認證錯誤 | Google 認證錯誤 + Supabase 認證錯誤 |

**Email/Password 錯誤處理**:
```dart
onLogin: (loginData) async {
  try {
    await Supabase.instance.client.auth.signInWithPassword(...);
  } catch (e) {
    return e.toString();  // 返回錯誤字串
  }
  return null;  // 成功
},
```

**Google 登入錯誤處理**:
```dart
// 在 GoogleAuthHandler 中
try {
  // Google 認證...
} on GoogleSignInException catch (e) {
  // 處理 Google 特定錯誤
  return SocialAuthResult.failure(
    message: '登入已取消',
    errorCode: 'CANCELED',
  );
} catch (e) {
  // 處理其他錯誤
  return SocialAuthResult.failure(
    message: '登入失敗: $e',
    errorCode: 'UNKNOWN_ERROR',
  );
}

// 在 _handleSocialAuthResult 中顯示錯誤
_showSnackBarWithLog(
  context,
  result.errorMessage ?? '登入失敗',
  backgroundColor: result.errorCode == 'CANCELED' ? Colors.orange : Colors.red,
  duration: const Duration(seconds: 3),
  logLevel: result.errorCode == 'CANCELED' ? 'WARNING' : 'ERROR',
);
```

---

### 7️⃣ **UI 反饋**

| 項目 | Email/Password | Google |
|------|----------------|--------|
| **Loading 狀態** | 由 `SocialAuthFlutterLogin` 管理 | 手動管理 `_isGoogleLoading` |
| **成功訊息** | ❌ 無（目前移除） | ✅ 有 SnackBar |
| **動畫** | ✅ 有成功動畫 | ❌ 無 |

**Email/Password**:
- 依賴 `SocialAuthFlutterLogin` 的內建 UI 反饋
- 成功動畫由 widget 自動處理

**Google**:
- 手動管理 loading 狀態：
  ```dart
  _isGoogleLoading = true;
  setState(() {});
  // ... 執行登入 ...
  _isGoogleLoading = false;
  setState(() {});
  ```
- 手動顯示 SnackBar（成功或失敗）

---

## 🔑 關鍵差異總結

### 1. **認證方式**
- **Email/Password**: 直接使用 Supabase `signInWithPassword()` API
- **Google**: 兩階段認證（先 Google OAuth，再 Supabase `signInWithIdToken()`）

### 2. **外部依賴**
- **Email/Password**: 無外部依賴，完全由 Supabase 處理
- **Google**: 依賴 `google_sign_in` package 和 Google OAuth 服務

### 3. **用戶資料載入**
- **Email/Password**: 依賴動畫延遲，無主動等待
- **Google**: 主動等待 500ms + 重試機制，確保用戶資料已載入

### 4. **錯誤處理**
- **Email/Password**: 簡單的 try-catch，返回錯誤字串
- **Google**: 結構化的 `SocialAuthResult`，包含錯誤碼和詳細訊息

### 5. **UI 反饋**
- **Email/Password**: 由 widget 自動處理，無需手動管理
- **Google**: 需要手動管理 loading 狀態和 SnackBar

---

## 📝 程式碼位置對照表

| 功能 | Email/Password | Google |
|------|----------------|--------|
| **觸發函數** | `onLogin` (Line 185-194) | `_signInWithGoogle` (Line 112-124) |
| **認證處理** | `signInWithPassword` (Line 187-189) | `GoogleAuthHandler.signIn()` → `completeSignInWithSupabase()` |
| **成功回調** | `onSubmitAnimationCompleted` (Line 219-225) | `_handleSocialAuthResult` (Line 63-109) |
| **錯誤處理** | try-catch 返回字串 | `SocialAuthResult` 物件 |

---

## 🎯 建議改進

### 1. **統一用戶資料載入等待**
建議在 `onSubmitAnimationCompleted` 中也添加等待機制，與 Google 登入一致：
```dart
onSubmitAnimationCompleted: () async {
  // 等待用戶資料載入（與 Google 登入一致）
  await Future.delayed(const Duration(milliseconds: 500));
  
  int retryCount = 0;
  while (retryCount < 10 && 
         SupabaseChatCore.instance.loggedUser == null) {
    await Future.delayed(const Duration(milliseconds: 200));
    retryCount++;
  }
  
  if (!mounted) return;
  
  if (widget.onLoginSuccess != null) {
    widget.onLoginSuccess!();
  } else {
    Navigator.of(context).pop();
  }
},
```

### 2. **統一錯誤處理**
考慮將 Email/Password 的錯誤處理也改為 `SocialAuthResult` 格式，保持一致性。

### 3. **統一 UI 反饋**
考慮在 Email/Password 登入成功時也顯示 SnackBar，與 Google 登入一致。

---

## 🎯 總結

兩種登入方式的核心差異在於：
1. **認證 API**: `signInWithPassword()` vs `signInWithIdToken()`
2. **前置步驟**: 無 vs Google OAuth 認證
3. **成功處理**: 簡單回調 vs 複雜的等待 + SnackBar 顯示
4. **錯誤處理**: 簡單字串 vs 結構化物件

雖然最終都會觸發相同的 `onAuthStateChange` stream 和 `RoomsPage` 更新，但中間的處理流程有顯著差異。Google 登入的流程更加複雜，因為需要處理外部服務的互動和更完整的錯誤處理。
