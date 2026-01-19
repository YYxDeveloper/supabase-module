# MemberProfilePage 初始化流程與方法執行順序

## 📋 類別架構

```
MemberProfilePage (StatefulWidget)
  └── _MemberProfilePageState (State)
```

## 🔄 初始化流程圖

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Widget 創建階段 (Widget Creation)                        │
│    MemberProfilePage(const MemberProfilePage({super.key}))  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. State 創建階段 (State Creation)                          │
│    createState() → 返回 _MemberProfilePageState 實例        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. 初始化階段 (Initialization)                              │
│    initState() {                                            │
│      super.initState()                                      │
│      ├─→ _checkCurrentUser()                                │
│      │     └─→ 檢查 Supabase 當前用戶                       │
│      │     └─→ 如果有用戶，更新所有狀態變數                 │
│      │                                                       │
│      └─→ GoogleSignIn.instance.authenticationEvents.listen()│
│            └─→ 監聽 Google Sign-In 事件                     │
│            └─→ 當事件發生時調用 _handleGoogleSignIn()       │
│    }                                                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. 構建階段 (Build Phase)                                    │
│    build(BuildContext context) {                            │
│      └─→ 根據狀態變數構建 UI                                │
│      └─→ 返回 Scaffold Widget                              │
│    }                                                         │
└─────────────────────────────────────────────────────────────┘
```

## 📊 詳細方法執行順序

### 階段 1: Widget 生命週期初始化

```
1. MemberProfilePage 建構子被調用
   └─> 創建 StatefulWidget 實例

2. createState() [line 11-13]
   └─> 返回 _MemberProfilePageState 實例
   └─> Flutter 框架自動調用

3. initState() [line 29-39]
   ├─> super.initState() [line 30]
   │   └─> 調用父類 State 的 initState()
   │
   ├─> _checkCurrentUser() [line 32]
   │   └─> 檢查 Supabase 當前用戶狀態
   │   └─> 如果有用戶，更新所有狀態變數：
   │       ├─> _userEmail
   │       ├─> _userId
   │       ├─> _userName
   │       ├─> _userAvatarUrl
   │       ├─> _userPhone
   │       ├─> _userCreatedAt
   │       ├─> _userLastSignInAt
   │       ├─> _userMetadata
   │       └─> _statusMessage = '已登入'
   │
   └─> GoogleSignIn.instance.authenticationEvents.listen() [line 34-38]
       └─> 設置事件監聽器
       └─> 當 GoogleSignInAuthenticationEventSignIn 事件發生時
           └─> 調用 _handleGoogleSignIn(event.user)

4. build() [line 480-710]
   └─> 首次構建 UI
   └─> 根據當前狀態變數顯示內容
```

### 階段 2: 狀態更新與重建

```
當 setState() 被調用時：
   └─> build() 方法會被重新調用
   └─> UI 根據新的狀態更新
```

## 🔍 核心方法詳細說明

### 1. initState() [line 29-39]
**執行時機**: Widget 插入到 Widget Tree 後立即執行（僅執行一次）

**執行內容**:
```dart
@override
void initState() {
  super.initState();                    // 1. 調用父類初始化
  _checkCurrentUser();                  // 2. 檢查當前用戶
  GoogleSignIn.instance                 // 3. 設置 Google Sign-In 監聽器
    .authenticationEvents
    .listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _handleGoogleSignIn(event.user);
      }
    });
}
```

### 2. _checkCurrentUser() [line 41-58]
**執行時機**: 
- initState() 中調用
- 頁面初始化時檢查是否有已登入用戶

**執行流程**:
```
_checkCurrentUser()
  ├─> 取得 Supabase.instance.client.auth.currentUser
  ├─> 如果 user != null
  │   └─> setState() {
  │       ├─> 更新 _userEmail
  │       ├─> 更新 _userId
  │       ├─> 更新 _userName (從 userMetadata)
  │       ├─> 更新 _userAvatarUrl (從 userMetadata)
  │       ├─> 更新 _userPhone
  │       ├─> 更新 _userCreatedAt
  │       ├─> 更新 _userLastSignInAt
  │       ├─> 更新 _userMetadata
  │       └─> 設置 _statusMessage = '已登入'
  │   }
  └─> 觸發 build() 重建 UI
```

### 3. build() [line 480-710]
**執行時機**: 
- initState() 後立即執行
- 每次 setState() 調用後執行
- Widget 需要重建時執行

**執行流程**:
```
build(BuildContext context)
  └─> 返回 Scaffold
      ├─> AppBar (根據 _userEmail 顯示登出按鈕)
      └─> Body
          ├─> 如果 _userEmail != null
          │   ├─> 顯示用戶頭像
          │   ├─> 顯示 "已登入" 文字
          │   └─> 顯示用戶資訊卡片
          │       └─> _buildInfoRow() 方法構建每一行資訊
          │
          ├─> 如果 _statusMessage != null
          │   └─> 顯示狀態訊息容器
          │
          ├─> Google 登入按鈕
          │   └─> onPressed: _signIn
          │
          └─> Apple 登入按鈕
              └─> onPressed: _signInWithApple
```

## 🔄 用戶互動流程

### Google 登入流程
```
用戶點擊 "Sign in with Google" 按鈕
  └─> _signIn() [line 128]
      ├─> setState() { _isLoading = true }
      ├─> GoogleSignIn.instance.authenticate()
      │   └─> 顯示 Google 登入畫面
      │
      ├─> 成功取得 GoogleSignInAccount
      │   └─> _handleGoogleSignIn(account) [line 60]
      │       ├─> 取得 idToken
      │       ├─> Supabase.instance.client.auth.signInWithIdToken()
      │       ├─> 更新所有用戶狀態變數
      │       └─> 顯示成功 SnackBar
      │
      └─> 錯誤處理
          └─> 根據錯誤類型顯示對應訊息
```

### Apple 登入流程
```
用戶點擊 "Sign in with Apple" 按鈕
  └─> _signInWithApple() [line 284]
      ├─> 檢查平台 (僅 iOS/macOS)
      ├─> setState() { _isAppleSignInLoading = true }
      ├─> SignInWithApple.getAppleIDCredential()
      │   └─> 顯示 Apple 登入畫面
      │
      ├─> 成功取得 credential
      │   ├─> Supabase.instance.client.auth.signInWithIdToken()
      │   ├─> 更新所有用戶狀態變數
      │   └─> 顯示成功 SnackBar
      │
      └─> 錯誤處理
          └─> 根據錯誤類型顯示對應訊息
```

### 登出流程
```
用戶點擊登出按鈕
  └─> _signOut() [line 440]
      ├─> GoogleSignIn.instance.signOut()
      ├─> Supabase.instance.client.auth.signOut()
      ├─> setState() {
      │   └─> 清空所有用戶狀態變數
      │   └─> _statusMessage = null
      │   └─> _userEmail = null
      │   └─> ... (其他變數都設為 null)
      │   }
      └─> 顯示登出成功 SnackBar
```

## 📝 狀態變數初始化順序

### 在類別中聲明 [line 16-26]
```dart
String? _statusMessage;        // null
String? _userEmail;            // null
String? _userId;               // null
String? _userName;              // null
String? _userAvatarUrl;         // null
String? _userPhone;             // null
String? _userCreatedAt;         // null
String? _userLastSignInAt;      // null
Map<String, dynamic>? _userMetadata;  // null
bool _isLoading = false;        // false
bool _isAppleSignInLoading = false;    // false
```

### 在 initState() 中初始化
```
1. super.initState() 執行
2. _checkCurrentUser() 執行
   └─> 如果有已登入用戶，更新所有狀態變數
3. Google Sign-In 監聽器設置完成
```

## 🎯 關鍵執行時機總結

| 方法 | 執行時機 | 執行次數 | 說明 |
|------|---------|---------|------|
| `createState()` | Widget 創建時 | 1次 | Flutter 框架自動調用 |
| `initState()` | State 創建後 | 1次 | 初始化邏輯 |
| `_checkCurrentUser()` | initState() 中 | 1次 | 檢查當前用戶 |
| `build()` | initState() 後 + 每次 setState() | 多次 | 構建 UI |
| `_signIn()` | 用戶點擊 Google 登入按鈕 | 多次 | 啟動 Google 登入 |
| `_signInWithApple()` | 用戶點擊 Apple 登入按鈕 | 多次 | 啟動 Apple 登入 |
| `_signOut()` | 用戶點擊登出按鈕 | 多次 | 執行登出 |

## 🔗 方法依賴關係圖

```
initState()
  ├─> _checkCurrentUser()
  │   └─> setState() ──> 觸發 build()
  │
  └─> GoogleSignIn.instance.authenticationEvents.listen()
      └─> _handleGoogleSignIn() ──> setState() ──> 觸發 build()

build()
  ├─> _buildInfoRow() (輔助方法，構建 UI)
  └─> _formatDateTimeString() (輔助方法，格式化日期)

_signIn()
  └─> _handleGoogleSignIn() ──> setState() ──> 觸發 build()

_signInWithApple()
  └─> setState() ──> 觸發 build()

_signOut()
  └─> setState() ──> 觸發 build()
```

## ⚠️ 注意事項

1. **initState() 僅執行一次**: 在 Widget 生命週期中，initState() 只會在 State 創建時執行一次，不會重複執行。

2. **setState() 觸發重建**: 每次調用 setState() 都會觸發 build() 方法重新執行，更新 UI。

3. **mounted 檢查**: 在異步操作後使用 setState() 或顯示 SnackBar 時，需要檢查 `mounted` 屬性，確保 Widget 仍在 Widget Tree 中。

4. **Google Sign-In 監聽器**: 在 initState() 中設置的事件監聽器會持續監聽，直到 Widget 被銷毀。

5. **狀態變數初始化**: 所有狀態變數在類別聲明時都有初始值（null 或 false），在 initState() 中通過 _checkCurrentUser() 進行實際初始化。
