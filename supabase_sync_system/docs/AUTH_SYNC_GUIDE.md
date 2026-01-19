# Auth Users 同步設定指南

## 📋 概述

自動同步 `auth.users` (認證系統) → `chats.users` (聊天系統)

## 🎯 功能

1. **自動同步新用戶** - 當新用戶註冊時，自動在 `chats.users` 建立記錄
2. **同步現有用戶** - 將目前所有 4 筆用戶同步到 `chats.users`
3. **更新同步** - 當用戶更新個人資料時，自動同步

## 🚀 設定步驟

### 步驟 1：執行同步 SQL

SQL 已複製到剪貼簿，請：

1. 前往 [Supabase SQL Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql)
2. 貼上 (`Cmd+V`) 並執行 (**RUN**)

### 步驟 2：驗證同步

執行驗證腳本：

```bash
./scripts/verify_sync.sh
```

或手動驗證：

```bash
# 查詢 auth.users
dart run scripts/query_auth_direct.dart

# 查詢 chats.users
./scripts/load_env.sh
```

## 📊 同步機制說明

### Trigger 函數

`sync_auth_user_to_chats()` 會在以下情況觸發：
- **INSERT**: 新用戶註冊時，自動建立 `chats.users` 記錄
- **UPDATE**: 用戶更新資料時，同步到 `chats.users`

### 資料對應

| auth.users | chats.users | 說明 |
|-----------|------------|------|
| `id` | `id` | 用戶 UUID |
| `raw_user_meta_data->>'first_name'` | `first_name` | 名字 |
| `raw_user_meta_data->>'last_name'` | `last_name` | 姓氏 |
| `email` 前綴 | `first_name` (備用) | 如果沒有名字，使用 email |
| `created_at` | `created_at` | 建立時間 |

## 🔍 同步結果預期

執行後應該看到：

```
auth.users:  4 筆
chats.users: 4 筆
✅ 同步成功！
```

### 同步的用戶

1. downlolow@gmail.com
2. always996@icloud.com
3. yyxdev@gmail.com
4. amazonforyoung@gmail.com

## 🛠️ 疑難排解

### 問題：同步後 chats.users 仍然是 0

**可能原因：**
1. SQL 執行失敗
2. 表格結構不符
3. RLS 政策阻擋

**解決方法：**
```sql
-- 檢查 chats.users 結構
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_schema = 'chats' AND table_name = 'users';

-- 手動插入測試
INSERT INTO chats.users (id, first_name, last_name)
VALUES (gen_random_uuid(), 'Test', 'User');
```

### 問題：觸發器沒有自動執行

**檢查觸發器狀態：**
```sql
SELECT * FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';
```

## 📝 維護

### 重新同步所有用戶

如果需要重新同步，再次執行：

```sql
INSERT INTO chats.users (id, first_name, last_name, created_at, updated_at)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'first_name', split_part(au.email, '@', 1)),
  COALESCE(au.raw_user_meta_data->>'last_name', ''),
  au.created_at,
  NOW()
FROM auth.users au
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  updated_at = EXCLUDED.updated_at;
```

### 停用自動同步

```sql
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
```

### 重新啟用自動同步

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_auth_user_to_chats();
```

## 🔐 安全考量

- 觸發器函數使用 `SECURITY DEFINER`，以確保有權限寫入 `chats.users`
- 只同步必要的資料（id, name, timestamps）
- 不同步敏感資料（password, tokens）

## 📚 相關檔案

- `scripts/setup_auth_sync.sql` - 同步設定 SQL
- `scripts/verify_sync.sh` - 驗證腳本
- `scripts/query_auth_direct.dart` - 查詢 auth.users
- `scripts/check_users_count.dart` - 查詢 chats.users
