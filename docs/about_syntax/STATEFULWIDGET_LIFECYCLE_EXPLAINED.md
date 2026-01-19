# StatefulWidget 完整生命週期詳解

## 📋 類別架構（第 6-7 行）

```
MemberProfilePage (StatefulWidget)
  └── _MemberProfilePageState (State)
```

這個架構展示了 Flutter 中 StatefulWidget 的標準設計模式。

## 🔄 完整生命週期流程圖

```
┌─────────────────────────────────────────────────────────────┐
│ 階段 1: Widget 創建 (Widget Creation)                      │
│                                                             │
│  MemberProfilePage(const MemberProfilePage({super.key}))   │
│    └─> 創建 StatefulWidget 實例                              │
│    └─> Widget 尚未插入到 Widget Tree                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 2: State 創建 (State Creation)                        │
│                                                             │
│  createState() → 返回 _MemberProfilePageState 實例         │
│    └─> Flutter 框架自動調用                                 │
│    └─> State 物件被創建，但尚未初始化                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 3: Widget 插入 (Widget Insertion)                     │
│                                                             │
│  Widget 被插入到 Widget Tree                                │
│    └─> 此時 Widget 已經在 Tree 中                           │
│    └─> 但 State 尚未初始化                                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 4: State 初始化 (State Initialization)                │
│                                                             │
│  initState() {                                             │
│    super.initState()                                       │
│    ├─> _checkCurrentUser()                                 │
│    └─> GoogleSignIn.instance.authenticationEvents.listen()│
│  }                                                          │
│                                                             │
│  ⚠️ 重要：此時可以使用 context，但還不能使用 mounted        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 5: 首次構建 (First Build)                              │
│                                                             │
│  build(BuildContext context) {                             │
│    └─> 根據狀態變數構建 UI                                  │
│    └─> 返回 Widget Tree                                    │
│  }                                                          │
│                                                             │
│  ⚠️ 重要：此時 mounted = true                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 6: 運行中 (Running)                                    │
│                                                             │
│  ┌─────────────────────────────────────┐                   │
│  │ 用戶互動 → setState() → build()     │                   │
│  │ 用戶互動 → setState() → build()     │                   │
│  │ 用戶互動 → setState() → build()     │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
│  這個階段會重複執行，直到 Widget 被移除                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 7: Widget 更新 (Widget Update)                        │
│                                                             │
│  didUpdateWidget(MemberProfilePage oldWidget) {            │
│    └─> 當父 Widget 重建並傳入新的 Widget 時調用            │
│    └─> 可以比較 oldWidget 和 widget 的差異                 │
│  }                                                          │
│                                                             │
│  ⚠️ 注意：MemberProfilePage 沒有實作此方法                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 8: Widget 移除 (Widget Removal)                       │
│                                                             │
│  Widget 從 Widget Tree 中移除                               │
│    └─> 但 State 尚未銷毀                                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 階段 9: State 銷毀 (State Disposal)                         │
│                                                             │
│  dispose() {                                                │
│    └─> 清理資源（取消訂閱、關閉控制器等）                    │
│    └─> 調用 super.dispose()                                │
│  }                                                          │
│                                                             │
│  ⚠️ 注意：MemberProfilePage 沒有實作此方法                  │
│  ⚠️ 但應該在 dispose() 中取消 GoogleSignIn 監聽器           │
└─────────────────────────────────────────────────────────────┘
```

## 📊 StatefulWidget 生命週期方法完整列表

### 1. createState() [line 11-13]
```dart
@override
State<MemberProfilePage> createState() => _MemberProfilePageState();
```

**執行時機**: Widget 創建時，Flutter 框架自動調用  
**執行次數**: 1次  
**用途**: 創建對應的 State 物件  
**注意**: 必須返回 State 實例

### 2. initState() [line 29-39]
```dart
@override
void initState() {
  super.initState();
  _checkCurrentUser();
  GoogleSignIn.instance.authenticationEvents.listen(...);
}
```

**執行時機**: State 創建後，Widget 插入到 Tree 後立即執行  
**執行次數**: 1次（整個生命週期只執行一次）  
**用途**: 
- 初始化狀態變數
- 設置監聽器
- 執行一次性初始化邏輯

**⚠️ 重要限制**:
- 不能使用 `mounted`（此時還未設置）
- 不能使用 `context` 進行導航（可能導致錯誤）
- 必須調用 `super.initState()`

### 3. build() [line 480-710]
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(...);
}
```

**執行時機**: 
- initState() 後立即執行
- 每次 setState() 調用後
- Widget 需要重建時

**執行次數**: 多次（可能非常頻繁）  
**用途**: 根據當前狀態構建 UI

**⚠️ 重要原則**:
- 必須是純函數（pure function）
- 不能修改狀態（不能調用 setState）
- 不能執行耗時操作

### 4. didUpdateWidget() [未實作]
```dart
@override
void didUpdateWidget(MemberProfilePage oldWidget) {
  super.didUpdateWidget(oldWidget);
  // 比較 oldWidget 和 widget 的差異
  // 根據差異決定是否需要更新狀態
}
```

**執行時機**: 父 Widget 重建並傳入新的 Widget 時  
**執行次數**: 多次（當父 Widget 重建時）  
**用途**: 響應 Widget 屬性的變化

**⚠️ 注意**: MemberProfilePage 沒有實作此方法，因為它沒有可變屬性

### 5. setState() [多處使用]
```dart
setState(() {
  _userEmail = user.email;
  _isLoading = true;
});
```

**執行時機**: 需要更新狀態時手動調用  
**執行次數**: 多次  
**用途**: 標記狀態已改變，觸發 rebuild

**⚠️ 重要**:
- 必須在 State 類別中調用
- 會觸發 build() 方法
- 異步操作後需要檢查 `mounted`

### 6. dispose() [未實作，但應該實作]
```dart
@override
void dispose() {
  // 取消 GoogleSignIn 監聽器
  // 清理其他資源
  super.dispose();
}
```

**執行時機**: State 被永久移除時  
**執行次數**: 1次  
**用途**: 清理資源、取消訂閱、關閉控制器

**⚠️ 重要**: 
- MemberProfilePage 目前沒有實作 dispose()
- 應該取消在 initState() 中設置的監聽器
- 必須調用 `super.dispose()`

## 🔍 MemberProfilePage 實際生命週期執行順序

### 完整執行流程

```
1. Widget 創建
   └─> MemberProfilePage(const MemberProfilePage({super.key}))
       └─> 創建 StatefulWidget 實例

2. State 創建
   └─> createState()
       └─> 返回 _MemberProfilePageState()

3. Widget 插入
   └─> Widget 被插入到 Widget Tree

4. State 初始化
   └─> initState()
       ├─> super.initState()
       ├─> _checkCurrentUser()
       │   ├─> 檢查 Supabase 用戶
       │   └─> 如果有用戶，調用 setState() 更新狀態
       │       └─> 觸發 build()（但此時 initState 尚未完成）
       └─> GoogleSignIn.instance.authenticationEvents.listen()
           └─> 設置事件監聽器

5. 首次構建
   └─> build(context)
       └─> 構建 UI，顯示用戶資訊或登入按鈕

6. 運行中（重複執行）
   └─> 用戶點擊登入按鈕
       └─> _signIn() 或 _signInWithApple()
           └─> setState() 更新狀態
               └─> build() 重新執行
                   └─> UI 更新

7. Widget 更新（如果發生）
   └─> didUpdateWidget()（未實作，不會執行）

8. Widget 移除
   └─> Widget 從 Tree 中移除

9. State 銷毀
   └─> dispose()（未實作，但應該實作）
       └─> 清理資源
```

## ⚠️ 當前實作的問題與建議

### 問題 1: 缺少 dispose() 方法

**問題**: GoogleSignIn 監聽器在 initState() 中設置，但沒有在 dispose() 中取消

**建議修復**:
```dart
class _MemberProfilePageState extends State<MemberProfilePage> {
  StreamSubscription? _googleSignInSubscription;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    
    // 保存訂閱以便在 dispose 中取消
    _googleSignInSubscription = GoogleSignIn.instance
        .authenticationEvents
        .listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _handleGoogleSignIn(event.user);
      }
    });
  }

  @override
  void dispose() {
    // 取消監聽器，避免記憶體洩漏
    _googleSignInSubscription?.cancel();
    super.dispose();
  }
}
```

### 問題 2: initState() 中調用 setState()

**問題**: 在 `_checkCurrentUser()` 中調用 setState()，此時 initState() 尚未完成

**影響**: 雖然可以正常運作，但可能導致 build() 在 initState() 完成前被調用

**建議**: 這是可以接受的，因為 Flutter 會正確處理這種情況

## 📝 生命週期方法對照表

| 方法 | 執行時機 | 執行次數 | 是否實作 | 用途 |
|------|---------|---------|---------|------|
| `createState()` | Widget 創建時 | 1次 | ✅ | 創建 State |
| `initState()` | State 創建後 | 1次 | ✅ | 初始化 |
| `build()` | initState() 後 + setState() | 多次 | ✅ | 構建 UI |
| `didUpdateWidget()` | Widget 更新時 | 多次 | ❌ | 響應屬性變化 |
| `setState()` | 手動調用 | 多次 | ✅ | 更新狀態 |
| `dispose()` | State 銷毀時 | 1次 | ❌ | 清理資源 |

## 🎯 關鍵要點總結

1. **initState() 只執行一次**: 用於一次性初始化
2. **build() 會頻繁執行**: 必須是純函數，不能有副作用
3. **setState() 觸發重建**: 每次調用都會觸發 build()
4. **dispose() 必須實作**: 清理在 initState() 中設置的資源
5. **mounted 檢查**: 異步操作後使用 setState() 前必須檢查

## 🔗 相關資源

- [Flutter StatefulWidget 官方文檔](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [Flutter State 官方文檔](https://api.flutter.dev/flutter/widgets/State-class.html)
- [Flutter 生命週期最佳實踐](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)
