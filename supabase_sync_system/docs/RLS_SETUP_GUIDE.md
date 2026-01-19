# Supabase RLS (Row Level Security) 設定指南

## 問題說明

當前 `chats.users` 表格的 RLS 政策限制了 API 查詢，導致使用 `anon` key 無法讀取用戶資料。

## 解決步驟

### 步驟 1：前往 Supabase Dashboard SQL Editor

1. 開啟瀏覽器，前往 [Supabase Dashboard](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo)
2. 點擊左側選單的 **SQL Editor**
3. 點擊 **New query** 建立新的查詢

### 步驟 2：檢查現有 RLS 設定（可選）

執行 `scripts/check_rls_policies.sql` 中的 SQL 查詢，了解目前的 RLS 狀態。

### 步驟 3：執行 RLS 設定腳本

將 `scripts/setup_users_rls.sql` 的內容複製到 SQL Editor 中，然後點擊 **Run** 執行。

**重要提示：**
- 腳本預設允許 **已認證用戶** 讀取所有用戶資料
- 如果你需要允許 **匿名用戶** 也能讀取（例如公開的用戶列表），請取消腳本中相關部分的註解

### 步驟 4：選擇適合的政策

根據你的應用需求，選擇以下其中一種方案：

#### 方案 A：允許匿名用戶讀取（適合公開用戶列表）

在 `setup_users_rls.sql` 中取消以下部分的註解：

```sql
DROP POLICY IF EXISTS "Enable read access for anon users" ON chats.users;
CREATE POLICY "Enable read access for anon users" 
ON chats.users
FOR SELECT
TO anon
USING (true);
```

✅ **優點：** 查詢腳本使用 anon key 即可直接運作
❌ **缺點：** 任何人都能讀取用戶列表（確保不包含敏感資料）

#### 方案 B：只允許已認證用戶讀取（推薦）

保持腳本預設設定即可。

✅ **優點：** 更安全，符合最佳實踐
❌ **缺點：** 查詢腳本需要使用已認證用戶的 token

### 步驟 5：驗證設定

執行更新後的查詢腳本：

```bash
dart run scripts/check_users_count.dart
```

如果設定正確（方案 A），應該能看到 2 筆用戶記錄。

## RLS 政策說明

### 什麼是 RLS？

Row Level Security (RLS) 是 PostgreSQL 的安全功能，可以控制哪些用戶可以存取哪些資料列。

### 為什麼需要 RLS？

- **安全性：** 防止未授權的資料存取
- **隔離性：** 確保用戶只能存取應該看到的資料
- **合規性：** 符合資料保護法規要求

### 常見的 RLS 模式

1. **公開讀取：** `USING (true)` - 允許所有人讀取
2. **只讀自己的資料：** `USING (auth.uid() = id)` - 只能存取自己的記錄
3. **基於角色：** 根據用戶角色決定存取權限

## 進階配置

### 測試 RLS 政策

在 SQL Editor 中，可以使用以下語法測試特定角色的存取：

```sql
-- 測試 anon 角色
SET ROLE anon;
SELECT * FROM chats.users;
RESET ROLE;

-- 測試 authenticated 角色
SET ROLE authenticated;
SELECT * FROM chats.users;
RESET ROLE;
```

### 查看所有表格的 RLS 狀態

```sql
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'chats'
ORDER BY tablename;
```

## 疑難排解

### 問題：執行腳本後仍然查詢不到資料

1. **檢查是否選擇了方案 A**（允許 anon 用戶讀取）
2. **確認 RLS 政策已成功建立**（執行驗證查詢）
3. **檢查 API key 是否正確**
4. **查看查詢腳本的調試輸出**

### 問題：不確定應該選擇哪個方案

- 如果是**內部系統**或需要高安全性 → 選擇方案 B
- 如果是**公開的社交功能**（如用戶列表、搜尋） → 選擇方案 A

## 參考資源

- [Supabase RLS 官方文件](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS 文件](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
