# 🔄 認證流程說明：從 Email/Password 登入到顯示 RoomsPage

## 📋 流程概覽

```
用戶輸入 Email & Password
    ↓
點擊 Submit 按鈕
    ↓
SocialAuthScreen.onLogin() 被觸發
    ↓
Supabase Auth API 驗證
    ↓
認證成功 → onAuthStateChange Stream 觸發
    ↓
SupabaseChatCore 自動載入用戶資料
    ↓
onSubmitAnimationCompleted() 被觸發
    ↓
呼叫 onLoginSuccess() callback
    ↓
RoomsPage 的 StreamBuilder 偵測到狀態變更
    ↓
重新構建 Widget，顯示聊天室列表
```

---

## 🔍 詳細流程分析

### 階段 1: 用戶輸入與提交 (SocialAuthScreen)

**檔案位置**: `social_auth_screen.dart` (Line 182-192)

```dart
onLogin: (loginData) async {
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: loginData.name,      // 用戶輸入的 email
      password: loginData.password, // 用戶輸入的 password
    );
  } catch (e) {
    return e.toString();  // 返回錯誤訊息
  }
  return null;  // 返回 null 表示成功
},
```

**流程說明**:
1. 用戶在 `SocialAuthFlutterLogin` widget 中輸入 email 和 password
2. 點擊 "Login" 按鈕後，`onLogin` callback 被觸發
3. 呼叫 `Supabase.instance.client.auth.signInWithPassword()` 進行認證
4. 如果認證失敗，返回錯誤訊息（會顯示在 UI 上）
5. 如果認證成功，返回 `null`（觸發成功動畫）

---

### 階段 2: 認證狀態變更監聽 (SupabaseChatCore)

**檔案位置**: `supabase_chat_core.dart` (Line 15-39)

```dart
SupabaseChatCore._privateConstructor() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    if (loggedSupabaseUser != null) {
      // 載入用戶資料到 SupabaseChatCore
      _loggedUser = await user(uid: loggedSupabaseUser!.id);
      
      // 設定線上狀態頻道
      if (_currentUserOnlineStatusChannel == null) {
        _currentUserOnlineStatusChannel ??=
            _getUserOnlineStatusChannel(loggedSupabaseUser!.id);
        _currentUserOnlineStatusChannel?.subscribe(...);
      }
    } else {
      // 登出時清理資料
      _loggedUser = null;
      await _currentUserOnlineStatusChannel?.unsubscribe();
      _currentUserOnlineStatusChannel = null;
    }
  });
}
```

**流程說明**:
1. `SupabaseChatCore` 在初始化時就開始監聽 `onAuthStateChange` stream
2. 當 `signInWithPassword()` 成功後，Supabase 會觸發認證狀態變更事件
3. `SupabaseChatCore` 自動偵測到 `loggedSupabaseUser` 不為 null
4. 自動從資料庫載入用戶資料到 `_loggedUser`
5. 設定 Realtime 線上狀態頻道

**關鍵點**: 這個過程是**自動的**，不需要手動呼叫！

---

### 階段 3: 登入成功回調 (SocialAuthScreen)

**檔案位置**: `social_auth_screen.dart` (Line 216-222)

```dart
onSubmitAnimationCompleted: () {
  if (widget.onLoginSuccess != null) {
    widget.onLoginSuccess!();  // 呼叫外部傳入的 callback
  } else {
    Navigator.of(context).pop();  // 如果沒有 callback，關閉當前頁面
  }
},
```

**流程說明**:
1. 當 `onLogin` 返回 `null`（成功）後，`SocialAuthFlutterLogin` 會播放成功動畫
2. 動畫完成後，`onSubmitAnimationCompleted` 被觸發
3. 如果有 `onLoginSuccess` callback，會呼叫它
4. 如果沒有 callback，會關閉當前頁面（`Navigator.pop()`）

**注意**: 在 `social_auth_screen.dart` 中，登入成功後會等待用戶資料載入（Line 72-79）：
```dart
// 等待用戶資料被載入
await Future.delayed(const Duration(milliseconds: 500));

// 確保用戶資料已載入
int retryCount = 0;
while (retryCount < 10 && SupabaseChatCore.instance.loggedUser == null) {
  await Future.delayed(const Duration(milliseconds: 200));
  retryCount++;
}
```

---

### 階段 4: RoomsPage 狀態更新

**檔案位置**: `rooms_page.dart` (Line 272-294)

```dart
@override
Widget build(BuildContext context) {
  // 使用 StreamBuilder 監聽登入狀態
  return StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, authSnapshot) {
      // 檢查當前登入用戶
      final currentSession = authSnapshot.data?.session ??
          Supabase.instance.client.auth.currentSession;
      final loggedSupabaseUser = currentSession?.user;
      final loggedUser = SupabaseChatCore.instance.loggedUser;

      // 如果沒有登入用戶，顯示 SocialAuthScreen
      if (loggedUser == null || loggedSupabaseUser == null) {
        return SocialAuthScreen(
          onLoginSuccess: () {
            // 登入成功後會自動觸發狀態更新，StreamBuilder 會重新構建
            if (mounted) {
              setState(() {});
            }
          },
        );
      }

      // 如果有登入用戶，顯示原本的 RoomsPage 內容
      return Scaffold(
        appBar: AppBar(...),
        body: Column(...),  // 聊天室列表
      );
    },
  );
}
```

**流程說明**:
1. `RoomsPage` 使用 `StreamBuilder<AuthState>` 監聽認證狀態
2. 初始狀態：`loggedUser == null`，顯示 `SocialAuthScreen`
3. 當用戶登入成功：
   - `onAuthStateChange` stream 發出新事件
   - `StreamBuilder` 自動重新構建
   - `loggedUser` 現在不為 null（由 `SupabaseChatCore` 自動載入）
   - `loggedSupabaseUser` 也不為 null（從 Supabase Auth 取得）
4. 條件判斷通過，顯示 `Scaffold`（聊天室列表）
5. `onLoginSuccess` callback 中的 `setState()` 確保 UI 立即更新

---

## 🔑 關鍵技術點

### 1. **Reactive State Management（響應式狀態管理）**

使用 `StreamBuilder` 和 `onAuthStateChange` stream 實現響應式更新：
- 不需要手動檢查登入狀態
- 認證狀態變更時自動更新 UI
- 符合 Flutter 的響應式設計模式

### 2. **自動用戶資料載入**

`SupabaseChatCore` 在監聽到認證成功後，自動：
- 從資料庫載入用戶資料
- 設定 Realtime 線上狀態
- 更新 `loggedUser` 屬性

### 3. **雙重驗證檢查**

`RoomsPage` 檢查兩個條件：
- `loggedSupabaseUser`: Supabase Auth 的用戶（認證層）
- `loggedUser`: SupabaseChatCore 的用戶（業務層）

確保兩個層面都準備好才顯示聊天室列表。

---

## 📊 時序圖

```
時間軸 →
[用戶輸入] → [點擊 Submit] → [Supabase 驗證] → [onAuthStateChange 觸發]
                                                      ↓
[SupabaseChatCore 載入用戶] ← ← ← ← ← ← ← ← ← ← ← ← ←
                                                      ↓
[onSubmitAnimationCompleted] → [onLoginSuccess()] → [setState()]
                                                      ↓
[StreamBuilder 重新構建] → [顯示 RoomsPage]
```

---

## 🐛 常見問題與解決方案

### Q1: 為什麼登入後還是顯示登入畫面？

**A**: 可能是 `SupabaseChatCore.instance.loggedUser` 還沒有載入完成。解決方案：
- 檢查 `onAuthStateChange` 是否正常觸發
- 確認資料庫中的用戶資料是否存在
- 檢查 `SupabaseChatCore` 的初始化是否完成

### Q2: 登入成功但 `loggedUser` 為 null？

**A**: 可能是資料庫查詢失敗。檢查：
- 資料庫中 `chats.users` 表是否有對應的用戶記錄
- 用戶 ID 是否正確
- 資料庫權限是否正確設定

### Q3: StreamBuilder 沒有重新構建？

**A**: 確保：
- `onAuthStateChange` stream 正常運作
- `setState()` 在 `mounted` 狀態下呼叫
- `onLoginSuccess` callback 正確傳遞

---

## 📝 程式碼關鍵位置總結

| 階段 | 檔案 | 行數 | 關鍵函數/變數 |
|------|------|------|----------------|
| 輸入提交 | `social_auth_screen.dart` | 182-192 | `onLogin()` |
| 認證 API | Supabase SDK | - | `auth.signInWithPassword()` |
| 狀態監聽 | `supabase_chat_core.dart` | 15-39 | `onAuthStateChange.listen()` |
| 用戶載入 | `supabase_chat_core.dart` | 17 | `user(uid: ...)` |
| 成功回調 | `social_auth_screen.dart` | 216-222 | `onSubmitAnimationCompleted()` |
| UI 更新 | `rooms_page.dart` | 274-294 | `StreamBuilder<AuthState>` |

---

## 🎯 總結

整個流程的核心是**響應式狀態管理**：
1. 用戶操作觸發認證
2. Supabase 發出狀態變更事件
3. `SupabaseChatCore` 自動載入資料
4. `StreamBuilder` 自動更新 UI

這種設計模式讓程式碼更加簡潔，不需要手動管理複雜的狀態同步邏輯。
