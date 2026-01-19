# 如何在 Supabase Dashboard 執行 SQL

完整的圖文教學，教你如何在 Supabase Dashboard 的 SQL Editor 中執行 SQL 語句。

## 📋 目錄

1. [前置準備](#前置準備)
2. [步驟 1：開啟 SQL Editor](#步驟-1開啟-sql-editor)
3. [步驟 2：建立新查詢](#步驟-2建立新查詢)
4. [步驟 3：貼上 SQL](#步驟-3貼上-sql)
5. [步驟 4：執行 SQL](#步驟-4執行-sql)
6. [步驟 5：檢查結果](#步驟-5檢查結果)
7. [常見問題](#常見問題)
8. [實用技巧](#實用技巧)

---

## 前置準備

### ✅ 需要準備的東西

- [ ] Supabase 帳號（已登入）
- [ ] 專案存取權限
- [ ] 要執行的 SQL 語句
- [ ] 網路瀏覽器（推薦 Chrome 或 Safari）

### 📌 專案資訊

```
專案名稱：二手拍賣網站MVP功能
專案 ID：dknjuzjbudprjrgdzaeo
Dashboard URL：https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo
```

---

## 步驟 1：開啟 SQL Editor

### 方法 A：直接連結（最快）

**點擊這個連結直接開啟 SQL Editor**：

```
https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql
```

或使用終端機快速開啟：

```bash
open https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql
```

### 方法 B：從 Dashboard 導覽

1. **前往 Supabase Dashboard**
   ```
   https://supabase.com/dashboard
   ```

2. **選擇你的專案**
   - 找到「二手拍賣網站MVP功能」專案
   - 點擊進入專案

3. **點擊左側選單的 SQL Editor**
   ```
   Dashboard
   ├── Home
   ├── Table Editor
   ├── Authentication
   ├── Storage
   ├── 📝 SQL Editor  ← 點這裡
   ├── Database
   └── ...
   ```

---

## 步驟 2：建立新查詢

### 選項 A：使用 New Query（推薦）

進入 SQL Editor 後，你會看到：

```
┌─────────────────────────────────────────────────┐
│  SQL Editor                                     │
│                                                 │
│  [+ New query]  [Templates ▼]  [Saved queries] │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │                                           │ │
│  │  -- 在這裡輸入或貼上你的 SQL            │ │
│  │                                           │ │
│  │                                           │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  [RUN] [Save]                                   │
└─────────────────────────────────────────────────┘
```

**點擊左上角的 `+ New query` 按鈕**

### 選項 B：使用現有查詢

如果你之前有儲存過查詢：
- 點擊 `Saved queries` 
- 選擇你要的查詢
- 編輯後執行

---

## 步驟 3：貼上 SQL

### 🎯 本專案常用的 SQL

#### 同步 Auth Users 到 Chats Users

如果剪貼簿還沒有 SQL，先執行：

```bash
pbcopy < scripts/setup_auth_sync.sql
```

然後在 SQL Editor 中：

1. **點擊編輯區域**
2. **按 `Cmd+V`（Mac）或 `Ctrl+V`（Windows）貼上**

你應該會看到類似這樣的 SQL：

```sql
-- ============================================
-- Auth Users → Chats Users 自動同步設定
-- ============================================

-- 步驟 1: 建立觸發器函數
CREATE OR REPLACE FUNCTION public.sync_auth_user_to_chats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  ...
END;
$$;

-- 步驟 2: 建立觸發器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_auth_user_to_chats();

-- 步驟 3: 同步現有用戶
INSERT INTO chats.users (...)
SELECT ...
FROM auth.users au
...
```

### 📝 檢查清單

貼上後請確認：

- [ ] SQL 完整（沒有被截斷）
- [ ] 開頭和結尾都有
- [ ] 沒有奇怪的格式問題

---

## 步驟 4：執行 SQL

### 🚀 執行方式

找到右下角或左下角的 **綠色 RUN 按鈕**：

```
┌───────────────────────────────────────────┐
│  -- Your SQL here                         │
│  ...                                      │
│                                           │
└───────────────────────────────────────────┘

[▶ RUN]  [💾 Save]
```

**點擊 `RUN` 按鈕**

或使用快捷鍵：
- **Mac**: `Cmd + Enter`
- **Windows**: `Ctrl + Enter`

### ⏱️ 執行過程

執行時你會看到：

```
Executing query...  ⌛
```

通常需要 1-5 秒，複雜的 SQL 可能需要更長時間。

---

## 步驟 5：檢查結果

### ✅ 成功的情況

執行成功後，你會在底部看到結果：

#### 情況 A：有返回資料

```
┌──────────────────────────────────────┐
│ Results                              │
├──────────────────────────────────────┤
│  source      | count                 │
├──────────────────────────────────────┤
│  auth.users  | 4                     │
│  chats.users | 4                     │
└──────────────────────────────────────┘

✓ Success. Rows: 2
```

#### 情況 B：DDL 語句（CREATE, ALTER, DROP）

```
┌──────────────────────────────────────┐
│ Results                              │
├──────────────────────────────────────┤
│  ✓ Successfully executed             │
│                                      │
│  - Created function: sync_auth_...  │
│  - Created trigger: on_auth_user... │
│  - Inserted 4 rows                  │
└──────────────────────────────────────┘

✓ Success
```

#### 情況 C：INSERT/UPDATE/DELETE

```
✓ Success. Affected rows: 4
```

### ❌ 錯誤的情況

如果出現錯誤，會顯示紅色訊息：

```
┌──────────────────────────────────────┐
│ ❌ Error                             │
├──────────────────────────────────────┤
│  ERROR: relation "chats.users"       │
│  does not exist                      │
│                                      │
│  LINE 1: INSERT INTO chats.users ... │
└──────────────────────────────────────┘
```

常見錯誤請參考 [常見問題](#常見問題) 章節。

---

## 常見問題

### ❓ Q1: 執行後沒有任何反應

**可能原因**：
- 網路連線問題
- 瀏覽器凍結
- SQL 語法錯誤但沒顯示

**解決方法**：
1. 重新整理頁面（`Cmd+R` 或 `F5`）
2. 再次執行
3. 檢查瀏覽器 Console（`F12` → Console）

### ❓ Q2: 顯示 "Permission denied"

**錯誤訊息**：
```
ERROR: permission denied for table users
```

**可能原因**：
- RLS (Row Level Security) 政策限制
- 沒有足夠的權限

**解決方法**：

```sql
-- 方法 1: 使用 SECURITY DEFINER
CREATE OR REPLACE FUNCTION your_function()
RETURNS ...
LANGUAGE plpgsql
SECURITY DEFINER  -- 加上這行
AS $$
...
$$;

-- 方法 2: 暫時關閉 RLS（不建議用於生產環境）
ALTER TABLE chats.users DISABLE ROW LEVEL SECURITY;
```

### ❓ Q3: 表格不存在

**錯誤訊息**：
```
ERROR: relation "chats.users" does not exist
```

**解決方法**：

1. **檢查 Schema**
   ```sql
   -- 確認表格存在
   SELECT tablename 
   FROM pg_tables 
   WHERE schemaname = 'chats';
   ```

2. **檢查表格名稱**
   - 可能是 `public.users` 而不是 `chats.users`
   - 注意大小寫

3. **建立表格**（如果不存在）
   ```sql
   CREATE TABLE chats.users (
     id UUID PRIMARY KEY,
     first_name TEXT,
     last_name TEXT,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```

### ❓ Q4: 語法錯誤

**錯誤訊息**：
```
ERROR: syntax error at or near "..."
```

**解決方法**：
1. 檢查 SQL 是否完整
2. 確認沒有多餘的分號
3. 檢查括號是否匹配
4. 重新複製 SQL

### ❓ Q5: 觸發器已存在

**錯誤訊息**：
```
ERROR: trigger "on_auth_user_created" already exists
```

**解決方法**：
```sql
-- 先刪除舊的觸發器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 然後重新建立
CREATE TRIGGER on_auth_user_created ...
```

---

## 實用技巧

### 💡 技巧 1：使用註解

在 SQL 中加入註解幫助理解：

```sql
-- 這是單行註解

/* 
   這是
   多行註解
*/

SELECT * FROM users; -- 行末註解
```

### 💡 技巧 2：分段執行

選取部分 SQL 來執行：

1. **用滑鼠選取**你想執行的部分
2. **按 RUN** 或 `Cmd+Enter`
3. 只有被選取的部分會執行

範例：
```sql
-- 只想執行這個
SELECT COUNT(*) FROM auth.users;  ← 選取這行

-- 不想執行這個
DROP TABLE dangerous_table;
```

### 💡 技巧 3：儲存常用查詢

執行成功後：

1. **點擊 `Save` 按鈕**
2. **輸入查詢名稱**（例如：「同步 Auth Users」）
3. **下次從 `Saved queries` 快速取用**

### 💡 技巧 4：使用 Template

SQL Editor 提供預設範本：

1. **點擊 `Templates` 下拉選單**
2. **選擇範本類型**：
   - Create table
   - Create function
   - Create trigger
   - RLS policies
3. **修改範本內容**

### 💡 技巧 5：快捷鍵

| 功能 | Mac | Windows |
|------|-----|---------|
| 執行 SQL | `Cmd + Enter` | `Ctrl + Enter` |
| 儲存查詢 | `Cmd + S` | `Ctrl + S` |
| 新查詢 | `Cmd + K` | `Ctrl + K` |
| 格式化 SQL | `Shift + Cmd + F` | `Shift + Ctrl + F` |
| 註解/取消註解 | `Cmd + /` | `Ctrl + /` |

### 💡 技巧 6：查看執行歷史

在 SQL Editor 中可以看到最近執行的查詢：

1. **點擊左側的「History」**
2. **選擇之前執行過的 SQL**
3. **再次執行或修改**

### 💡 技巧 7：匯出結果

執行查詢後，可以匯出結果：

1. **點擊結果表格右上角的 `⋮` 選單**
2. **選擇 `Export`**
3. **選擇格式**：
   - CSV
   - JSON
   - Excel

---

## 📚 本專案常用 SQL 範例

### 範例 1：查詢用戶數量

```sql
-- 查詢 auth.users
SELECT COUNT(*) as total_auth_users FROM auth.users;

-- 查詢 chats.users
SELECT COUNT(*) as total_chats_users FROM chats.users;

-- 同時查詢
SELECT 
  'auth.users' as source,
  COUNT(*) as count
FROM auth.users
UNION ALL
SELECT 
  'chats.users' as source,
  COUNT(*) as count
FROM chats.users;
```

### 範例 2：查看同步狀態

```sql
-- 檢查觸發器
SELECT * FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- 檢查函數
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'sync_auth_user_to_chats';
```

### 範例 3：手動同步單一用戶

```sql
-- 替換 'USER_ID_HERE' 為實際的 user id
INSERT INTO chats.users (id, first_name, last_name, created_at, updated_at)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'first_name', split_part(email, '@', 1)),
  COALESCE(raw_user_meta_data->>'last_name', ''),
  created_at,
  NOW()
FROM auth.users
WHERE id = 'USER_ID_HERE'
ON CONFLICT (id) DO UPDATE SET updated_at = NOW();
```

### 範例 4：檢查 RLS 政策

```sql
-- 查看所有 RLS 政策
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'chats';
```

---

## 🎯 完整執行流程總結

### 快速版（1 分鐘）

```bash
# 1. 複製 SQL
pbcopy < scripts/setup_auth_sync.sql

# 2. 開啟 Dashboard
open https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql

# 3. 在瀏覽器中：
# - 點擊 New query
# - Cmd+V 貼上
# - 點擊 RUN
# - 檢查結果
```

### 詳細版（完整步驟）

1. ✅ **準備 SQL**
   - 確認要執行的 SQL 檔案
   - 複製到剪貼簿

2. ✅ **開啟 SQL Editor**
   - 前往 Dashboard
   - 點擊 SQL Editor

3. ✅ **建立新查詢**
   - 點擊 New query
   - 或選擇 Saved queries

4. ✅ **貼上 SQL**
   - Cmd+V 貼上
   - 檢查完整性

5. ✅ **執行 SQL**
   - 點擊 RUN 按鈕
   - 或 Cmd+Enter

6. ✅ **檢查結果**
   - 確認成功訊息
   - 檢查返回資料
   - 處理錯誤（如有）

7. ✅ **驗證結果**
   - 執行驗證查詢
   - 或使用本地腳本驗證

---

## 🔗 相關資源

### 本專案文件

- [完整實作流程](SUPABASE_USER_QUERY_AND_SYNC_FLOW.md)
- [快速參考](QUICK_REFERENCE.md)
- [同步設定指南](AUTH_SYNC_GUIDE.md)

### 官方文件

- [Supabase SQL Editor 文件](https://supabase.com/docs/guides/database/overview#the-sql-editor)
- [PostgreSQL 語法參考](https://www.postgresql.org/docs/current/sql.html)
- [Supabase 觸發器指南](https://supabase.com/docs/guides/database/postgres/triggers)

### 實用連結

- [SQL Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql)
- [Table Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/editor)
- [Authentication](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/auth/users)

---

## 📝 檢查清單

完成 SQL 執行後，請確認：

- [ ] SQL 執行成功（顯示綠色成功訊息）
- [ ] 沒有錯誤訊息
- [ ] 返回的結果符合預期
- [ ] 使用本地腳本驗證（`./scripts/verify_sync.sh`）
- [ ] 資料已正確同步
- [ ] 觸發器正常運作

---

**建立時間**: 2026-01-19  
**版本**: 1.0.0  
**維護者**: AI Assistant  
**專案**: Supabase User Query and Sync System

---

## 💬 需要幫助？

如果遇到問題：

1. 📖 查看本文件的[常見問題](#常見問題)章節
2. 📚 參考[完整實作流程](SUPABASE_USER_QUERY_AND_SYNC_FLOW.md)的疑難排解
3. 🔍 檢查 Supabase 官方文件
4. 💻 使用本專案的診斷工具

---

**祝你執行順利！** 🎉
