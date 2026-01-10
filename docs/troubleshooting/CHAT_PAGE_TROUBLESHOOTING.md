# Chat Page 故障排除指南

## 問題：Chat Page 顯示空白或無內容

### 已添加的改進

1. **錯誤訊息顯示**
   - 如果載入失敗，現在會顯示錯誤訊息
   - 提供「重試」按鈕

2. **Debug 輸出**
   - 在 console 中輸出詳細的診斷訊息
   - 包括用戶狀態、載入狀態、錯誤訊息

3. **連接檢查**
   - 自動檢查 Supabase 連接狀態
   - 顯示用戶登入狀態

---

## 常見問題與解決方案

### 問題 1: 顯示「請先登入以使用聊天功能」

**原因**: 用戶未登入

**解決方案**:
1. 確保用戶已通過 Supabase Auth 登入
2. 檢查 `Supabase.instance.client.auth.currentUser` 是否為 null
3. 查看 console 輸出確認用戶狀態

**檢查方法**:
```dart
final user = Supabase.instance.client.auth.currentUser;
print('用戶 ID: ${user?.id}');
```

---

### 問題 2: 顯示錯誤訊息「載入聊天室失敗」

**可能原因**:
1. Supabase 資料庫表尚未建立
2. RLS (Row Level Security) 政策未設置
3. Schema 未正確暴露

**解決方案**:

#### Step 1: 檢查資料庫表是否存在

`flutter_supabase_chat_core` 需要以下資料表：
- `chats` schema 中的表：
  - `users`
  - `rooms`
  - `rooms_l` (rooms list view)
  - `messages`
  - `messages_l` (messages list view)
  - `chats_assets` (storage bucket)

#### Step 2: 執行資料庫準備腳本

1. 下載或複製 `flutter_supabase_chat_core` 的準備腳本
   - 位置: `flutter_supabase_chat_core/example/utils/prepare.sh` (macOS/Linux)
   - 或 `flutter_supabase_chat_core/example/utils/prepare.ps1` (Windows)

2. 執行腳本（需要資料庫連接資訊）:
   ```bash
   cd flutter_supabase_chat_core/example/utils/
   ./prepare.sh \
     -h "your-postgres-host" \
     -p 5432 \
     -d "your-database-name" \
     -U "postgres"
   ```

3. 在 Supabase Dashboard 中暴露 `chats` schema:
   - 進入 Settings → Database
   - 找到 "Exposed schemas"
   - 添加 `chats` 到列表中

#### Step 3: 設置 RLS 政策

確保以下表有適當的 RLS 政策：
- `users`: 允許用戶讀取其他用戶資料
- `rooms`: 允許用戶讀取自己參與的房間
- `messages`: 允許用戶讀取自己參與房間的訊息

---

### 問題 3: 顯示載入動畫但永遠不結束

**原因**: 
- 資料庫查詢卡住或超時
- 網路連接問題

**解決方案**:
1. 檢查 console 的 debug 輸出
2. 確認 Supabase URL 和 Key 正確
3. 檢查網路連接

**Debug 輸出位置**:
- 查找 "開始載入聊天室..."
- 查找 "載入到 X 個聊天室"
- 查找任何錯誤訊息

---

### 問題 4: 顯示「尚無聊天室」但無法創建

**原因**:
- 沒有其他用戶可以聊天
- `users` 表中沒有資料

**解決方案**:

#### 創建用戶資料

當用戶首次登入時，需要在 `users` 表中創建記錄：

```dart
// 在用戶登入後調用
final user = Supabase.instance.client.auth.currentUser;
if (user != null) {
  final chatUser = types.User(
    id: user.id,
    firstName: user.userMetadata?['firstName'] ?? user.email?.split('@')[0] ?? 'User',
    lastName: user.userMetadata?['lastName'],
    imageUrl: user.userMetadata?['avatar_url'],
  );
  await SupabaseChatCore.instance.updateUser(chatUser);
}
```

#### 確保有至少兩個用戶

1. 使用不同帳號登入兩次
2. 確保兩個帳號都有在 `users` 表中創建記錄
3. 然後嘗試創建聊天室

---

### 問題 5: 聊天室列表空白但資料庫有資料

**原因**:
- `rooms_l` view 可能未正確建立
- RLS 政策阻止讀取
- 用戶 ID 不匹配

**檢查方法**:

1. 在 Supabase SQL Editor 中查詢:
   ```sql
   SELECT * FROM chats.rooms_l 
   WHERE "userId" = 'your-user-id';
   ```

2. 檢查 RLS 政策:
   ```sql
   SELECT * FROM pg_policies 
   WHERE schemaname = 'chats' AND tablename = 'rooms_l';
   ```

---

## Debug 步驟

### Step 1: 檢查 Console 輸出

運行應用程式並查看 console，應該看到：
```
=== Supabase 連接檢查 ===
Supabase URL: https://xxxxx.supabase.co
Supabase 已初始化: 是
當前用戶 ID: xxx-xxx-xxx
用戶 Email: user@example.com
=======================
開始載入聊天室...
當前用戶 ID: xxx-xxx-xxx
載入到 X 個聊天室
ChatPage build - 用戶: xxx-xxx-xxx, 載入中: false, 錯誤: null, 聊天室數量: X
```

### Step 2: 檢查 Supabase Dashboard

1. 進入 Supabase Dashboard
2. 檢查 Table Editor:
   - `chats.users` - 應該有用戶資料
   - `chats.rooms` - 應該有聊天室資料（如果有的話）
   - `chats.messages` - 應該有訊息資料（如果有的話）

3. 檢查 Database → API:
   - 確認 `chats` schema 已暴露
   - 檢查 RLS 政策

### Step 3: 測試 API 連接

在 Supabase Dashboard 的 SQL Editor 中執行:

```sql
-- 檢查當前用戶
SELECT auth.uid();

-- 檢查用戶表
SELECT * FROM chats.users LIMIT 10;

-- 檢查聊天室（替換為你的用戶 ID）
SELECT * FROM chats.rooms_l WHERE "userId" = 'your-user-id';
```

---

## 快速檢查清單

- [ ] 用戶已登入 (`auth.currentUser != null`)
- [ ] Supabase URL 和 Key 正確設置
- [ ] `chats` schema 已暴露
- [ ] 資料庫表已建立（users, rooms, messages 等）
- [ ] RLS 政策已設置
- [ ] `users` 表中有當前用戶的記錄
- [ ] 至少有一個其他用戶可以聊天
- [ ] 網路連接正常
- [ ] 查看 console 的 debug 輸出

---

## 取得幫助

如果問題仍然存在：

1. **收集資訊**:
   - Console 的完整 debug 輸出
   - Supabase Dashboard 中的錯誤日誌
   - 任何異常的堆疊追蹤

2. **檢查文件**:
   - [flutter_supabase_chat_core 官方文檔](https://flutter-supabase-chat-core.insideapp.it/)
   - [Supabase 設定指南](https://flutter-supabase-chat-core.insideapp.it/introduction/supabase-project-configuration/)

3. **驗證環境**:
   - Flutter 版本: `flutter --version`
   - Package 版本: `flutter pub deps`
   - Supabase 連接: 在 Dashboard 中測試查詢

---

## 下一步

如果所有檢查都通過但仍無法使用，請：

1. 重新運行應用程式
2. 查看最新的 console 輸出
3. 檢查是否有特定的錯誤訊息
4. 根據錯誤訊息查找對應的解決方案
