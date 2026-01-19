# Email/Password 登入到 RoomsPage 流程說明 - showName 重點

本文檔詳細說明從 Email/Password 登入到顯示 RoomsPage 的完整流程，**特別關注 showName 的上傳和顯示機制**。

---

## 📋 流程概覽

```
用戶輸入 Email/Password 
  ↓
SocialAuthScreen.onLogin/onSignup
  ↓
Supabase Auth 認證
  ↓
SupabaseChatCore.updateUser() (註冊時上傳 showName)
  ↓
SupabaseChatCore.onAuthStateChange 監聽器
  ↓
自動載入用戶資料 (fetchUser → showName 映射到 firstName)
  ↓
RoomsPage StreamBuilder 檢測到登入狀態
  ↓
SupabaseChatCore.rooms() 獲取房間列表
  ↓
processRoomRow() 處理房間資料 (showName → room.name)
  ↓
RoomTile 顯示房間名稱
```

---

## 🔐 階段 1: Email/Password 登入/註冊

### 1.1 登入流程 (Login)

**檔案**: `flutter_supabase_chat_core/packages/auth_package/lib/src/pages/social_auth_screen.dart`

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
  return null;
},
```

**重點**: 
- 登入時**不會**上傳 showName（因為用戶已存在，showName 已在資料庫中）
- 登入成功後觸發 `onAuthStateChange`，自動載入現有用戶資料

---

### 1.2 註冊流程 (Signup) - **showName 上傳關鍵步驟**

**檔案**: `flutter_supabase_chat_core/packages/auth_package/lib/src/pages/social_auth_screen.dart`

#### 步驟 1: 定義註冊表單欄位

```dart
additionalSignupFields: [
  UserFormField(
    keyName: 'display_name',  // ← 表單欄位名稱
    displayName: localizations.displayNameLabel,
    defaultValue: '${faker.person.firstName()} ${faker.person.lastName()}',
    fieldValidator: (value) {
      if (value == null || value == '') {
        return localizations.requiredFieldError;
      }
      return null;
    },
  ),
],
```

#### 步驟 2: 註冊並上傳 showName

```dart
onSignup: (signupData) async {
  try {
    // 1. 創建 Supabase Auth 用戶
    final response = await Supabase.instance.client.auth.signUp(
      email: signupData.name,
      password: signupData.password!,
    );
    
    // 2. 從表單取得 displayName
    final displayName = signupData.additionalSignupData!['display_name'];
    
    // 3. 上傳 showName 到資料庫
    await SupabaseChatCore.instance.updateUser(
      types.User(
        firstName: displayName,  // ← showName 存入 firstName（相容性處理）
        id: response.user!.id,
        lastName: null,
      ),
    );
  } catch (e) {
    return e.toString();
  }
  return null;
},
```

**關鍵點**:
- `display_name` 從表單取得
- 存入 `types.User.firstName`（因為 `types.User` 沒有 `showName` 欄位）
- 實際資料庫欄位是 `showName`（見下方 `updateUser()` 說明）

---

## 💾 階段 2: showName 上傳到資料庫

**檔案**: `flutter_supabase_chat_core/lib/src/class/supabase_chat_core.dart`

### updateUser() 方法

```dart
Future<void> updateUser(types.User user) async {
  // 從 types.User.firstName 提取 showName
  final showName = user.firstName?.trim().isNotEmpty == true
      ? user.firstName!.trim()
      : (user.lastName?.trim().isNotEmpty == true 
          ? user.lastName!.trim() 
          : null);

  // 更新資料庫的 showName 欄位
  await client.schema(config.schema).from(config.usersTableName).update({
    'showName': showName,  // ← 實際存入資料庫的欄位
    'imageUrl': user.imageUrl,
    'metadata': user.metadata,
    'role': user.role?.toShortString(),
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  }).eq('id', user.id);
}
```

**資料庫結構**:
- 資料庫欄位: `showName` (String)
- `types.User` 欄位: `firstName` (用於相容性，實際存的是 showName)
- 已移除: `firstName`、`lastName` 資料庫欄位

**映射關係**:
```
表單 display_name 
  → types.User.firstName 
  → 資料庫 showName
```

---

## 🔄 階段 3: 認證狀態變更與用戶資料載入

**檔案**: `flutter_supabase_chat_core/lib/src/class/supabase_chat_core.dart`

### 3.1 監聽認證狀態

```dart
SupabaseChatCore._privateConstructor() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    if (loggedSupabaseUser != null) {
      // 自動載入用戶資料
      _loggedUser = await user(uid: loggedSupabaseUser!.id);
      // ... 其他初始化邏輯
    } else {
      _loggedUser = null;
    }
  });
}
```

### 3.2 載入用戶資料 - **showName 讀取與映射**

**檔案**: `flutter_supabase_chat_core/lib/src/class/supabase_chat_core.dart`

```dart
Future<types.User?> user({required String uid}) async {
  final response = await client
      .schema(config.schema)
      .from(config.usersTableName)
      .select()
      .eq('id', uid)
      .limit(1);
  if (response.isEmpty) return null;

  // 將資料庫的 showName 映射到 types.User.firstName
  final data = Map<String, dynamic>.from(response.first);
  final showName = data['showName'] as String?;
  if (showName != null) {
    data['firstName'] = showName;  // ← 映射到 firstName
    data['lastName'] = null;
  }
  return types.User.fromJson(data);
}
```

**映射關係**:
```
資料庫 showName 
  → types.User.firstName 
  → 供 UI 使用
```

---

## 📱 階段 4: RoomsPage 顯示

**檔案**: `flutter_supabase_chat_core/packages/chat_package/lib/src/pages/rooms_page.dart`

### 4.1 檢測登入狀態

```dart
@override
Widget build(BuildContext context) {
  return StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, authSnapshot) {
      final loggedUser = SupabaseChatCore.instance.loggedUser;
      
      // 如果未登入，顯示登入頁面
      if (loggedUser == null || loggedSupabaseUser == null) {
        return SocialAuthScreen(
          onLoginSuccess: () {
            if (mounted) setState(() {});
          },
        );
      }
      
      // 已登入，顯示房間列表
      return Scaffold(/* ... */);
    },
  );
}
```

### 4.2 獲取房間列表

```dart
Future<void> _fetchPage(int offset) async {
  try {
    final newItems = await SupabaseChatCore.instance
        .rooms(filter: _filter, offset: offset, limit: _pageSize);
    // ... 處理分頁邏輯
  } catch (error) {
    _controller.error = error;
  }
}
```

---

## 🏠 階段 5: 房間資料處理 - **showName 轉換為 room.name**

**檔案**: `flutter_supabase_chat_core/lib/src/util.dart`

### 5.1 fetchUser() - 讀取用戶並映射 showName

```dart
Future<Map<String, dynamic>> fetchUser(
  SupabaseClient instance,
  String userId,
  String usersTableName,
  String schema, {
  String? role,
}) async {
  final data = (await instance
          .schema(schema)
          .from(usersTableName)
          .select()
          .eq('id', userId)
          .limit(1))
      .first;
  data['role'] = role;
  
  // 將資料庫的 showName 映射到 firstName（供 types.User 使用）
  final showName = data['showName'] as String?;
  if (showName != null) {
    data['firstName'] = showName;
    data['lastName'] = null;
  }
  
  return data;
}
```

### 5.2 processRoomRow() - **將 showName 轉換為房間名稱**

```dart
Future<types.Room> processRoomRow(
  Map<String, dynamic> data,
  User supabaseUser,
  SupabaseClient instance,
  String usersTableName,
  String schema,
) async {
  // ... 獲取用戶列表
  final users = await Future.wait(
    userIds.map((userId) => fetchUser(/* ... */)),
  );
  
  // 如果是直接聊天 (direct)，使用對方的 showName 作為房間名稱
  if (type == types.RoomType.direct.toShortString()) {
    final index = users.indexWhere(
      (u) => u['id'] != supabaseUser.id,
    );
    if (index >= 0) {
      final otherUser = users[index];
      imageUrl = otherUser['imageUrl'] as String?;
      
      // 🔑 關鍵步驟：從對方的 showName 設定房間名稱
      name = otherUser['showName'] as String? ??
             (otherUser['firstName'] != null || otherUser['lastName'] != null
                 ? '${otherUser['firstName'] ?? ''} ${otherUser['lastName'] ?? ''}'.trim()
                 : null);
      
      // 備用方案：如果 showName 為空，使用 email 或 id
      if (name == null || name.isEmpty) {
        name = otherUser['email'] as String? ?? 
               otherUser['id'] as String? ?? 
               '未命名用戶';
      }
    }
  }
  
  // 設定房間資料
  data['imageUrl'] = imageUrl;
  data['name'] = name;  // ← 房間名稱（來自對方的 showName）
  data['users'] = users;
  
  return types.Room.fromJson(data);
}
```

**關鍵邏輯**:
- **直接聊天 (direct)**: `room.name = 對方的 showName`
- **群組聊天 (group)**: `room.name = 群組名稱`（如果為空則使用備用名稱）

---

## 🎨 階段 6: RoomTile 顯示房間名稱

**檔案**: `flutter_supabase_chat_core/packages/chat_package/lib/src/widgets/room_tile.dart`

### 6.1 顯示房間名稱

```dart
@override
Widget build(BuildContext context) => ListTile(
  leading: _buildAvatar(room),  // 頭像（使用 room.name 的第一個字母）
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(room.name ?? ''),  // ← 顯示房間名稱（來自對方的 showName）
      // ... 時間和狀態圖示
    ],
  ),
  // ...
);
```

### 6.2 頭像顯示

```dart
Widget _buildAvatar(types.Room room) {
  final name = room.name ?? '';  // ← 使用房間名稱（來自 showName）
  
  final Widget child = CircleAvatar(
    backgroundColor: hasImage ? Colors.transparent : color,
    backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
    radius: 20,
    child: !hasImage
        ? Text(
            name.isEmpty ? '' : name[0].toUpperCase(),  // ← 顯示名稱首字母
            style: const TextStyle(color: Colors.white),
          )
        : null,
  );
  // ...
}
```

---

## 📊 完整資料流圖

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 註冊階段 (Signup)                                          │
├─────────────────────────────────────────────────────────────┤
│ 表單輸入: display_name = "張三"                               │
│   ↓                                                           │
│ signupData.additionalSignupData['display_name']              │
│   ↓                                                           │
│ types.User(firstName: "張三")                                 │
│   ↓                                                           │
│ SupabaseChatCore.updateUser()                                │
│   ↓                                                           │
│ 資料庫 users 表: showName = "張三"                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 2. 登入後載入用戶資料                                         │
├─────────────────────────────────────────────────────────────┤
│ onAuthStateChange 觸發                                        │
│   ↓                                                           │
│ SupabaseChatCore.user(uid)                                   │
│   ↓                                                           │
│ 資料庫查詢: showName = "張三"                                │
│   ↓                                                           │
│ 映射: data['firstName'] = "張三"                             │
│   ↓                                                           │
│ types.User.fromJson(data)                                    │
│   ↓                                                           │
│ SupabaseChatCore.loggedUser.firstName = "張三"               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 3. 載入房間列表                                               │
├─────────────────────────────────────────────────────────────┤
│ SupabaseChatCore.rooms()                                     │
│   ↓                                                           │
│ processRoomRow()                                             │
│   ↓                                                           │
│ fetchUser(對方用戶ID)                                        │
│   ↓                                                           │
│ 資料庫: showName = "李四"                                    │
│   ↓                                                           │
│ 映射: otherUser['showName'] = "李四"                          │
│   ↓                                                           │
│ room.name = "李四"                                           │
│   ↓                                                           │
│ types.Room(name: "李四")                                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 4. UI 顯示                                                    │
├─────────────────────────────────────────────────────────────┤
│ RoomTile(room: Room(name: "李四"))                           │
│   ↓                                                           │
│ Text(room.name) → 顯示 "李四"                                 │
│   ↓                                                           │
│ CircleAvatar child → Text("李")                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 關鍵要點總結

### showName 上傳流程
1. **註冊時**: `display_name` (表單) → `types.User.firstName` → 資料庫 `showName`
2. **更新時**: `SupabaseChatCore.updateUser()` 將 `firstName` 轉換為 `showName` 存入資料庫

### showName 讀取與顯示流程
1. **載入用戶**: 資料庫 `showName` → `types.User.firstName` (映射)
2. **處理房間**: `fetchUser()` 讀取對方的 `showName` → `processRoomRow()` 設定 `room.name`
3. **UI 顯示**: `RoomTile` 使用 `room.name` 顯示房間標題和頭像

### 資料映射關係
- **資料庫欄位**: `showName` (唯一真實欄位)
- **types.User 欄位**: `firstName` (相容性映射，實際存的是 showName)
- **表單欄位**: `display_name` (用戶輸入)
- **房間名稱**: `room.name` (直接聊天時 = 對方的 showName)

---

## 📝 注意事項

1. **相容性處理**: 
   - `types.User` 沒有 `showName` 欄位，所以使用 `firstName` 作為映射目標
   - 資料庫已移除 `firstName`/`lastName` 欄位，只保留 `showName`

2. **向後相容**:
   - `processRoomRow()` 中如果 `showName` 為空，會嘗試使用 `firstName` 或 `lastName`（舊資料）

3. **備用方案**:
   - 如果 `showName` 為空，使用 `email` 或 `id` 作為房間名稱
   - 如果都為空，使用 "未命名用戶" 或 "未命名對話"

---

## 🔍 相關檔案清單

- **認證頁面**: `packages/auth_package/lib/src/pages/social_auth_screen.dart`
- **核心類別**: `lib/src/class/supabase_chat_core.dart`
- **工具函數**: `lib/src/util.dart`
- **房間頁面**: `packages/chat_package/lib/src/pages/rooms_page.dart`
- **房間圖塊**: `packages/chat_package/lib/src/widgets/room_tile.dart`

---

**最後更新**: 2024-01-XX