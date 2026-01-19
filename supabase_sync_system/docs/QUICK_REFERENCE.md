# Supabase 用戶查詢與同步 - 快速參考

## 🚀 快速開始

### 查詢 Auth Users (認證系統用戶)

```bash
dart run scripts/query_auth_direct.dart
```

### 查詢 Chats Users (聊天系統用戶)

```bash
./scripts/load_env.sh
```

### 驗證同步狀態

```bash
./scripts/verify_sync.sh
```

---

## 📋 常用命令

### Supabase CLI

```bash
# 列出專案
supabase projects list

# 連接專案
supabase link --project-ref dknjuzjbudprjrgdzaeo

# 取得 API Keys
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo

# 修復 migration
supabase migration repair --status reverted <migration_id>
```

### 查詢命令

```bash
# 查詢 auth.users（需要 service_role key）
dart run scripts/query_auth_direct.dart

# 查詢 chats.users（需要 .env 設定）
export $(cat .env | grep -v '^#' | xargs) && dart run scripts/check_users_count.dart

# 或使用包裝腳本
./scripts/load_env.sh
```

### SQL 操作

```sql
-- 查詢 auth.users 數量
SELECT COUNT(*) FROM auth.users;

-- 查詢 chats.users 數量
SELECT COUNT(*) FROM chats.users;

-- 檢查同步狀態
SELECT 
  (SELECT COUNT(*) FROM auth.users) as auth_count,
  (SELECT COUNT(*) FROM chats.users) as chats_count;

-- 手動同步單一用戶
INSERT INTO chats.users (id, first_name, last_name, created_at, updated_at)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'first_name', split_part(email, '@', 1)),
  COALESCE(raw_user_meta_data->>'last_name', ''),
  created_at,
  NOW()
FROM auth.users
WHERE id = 'user_id_here'
ON CONFLICT (id) DO UPDATE SET updated_at = NOW();
```

---

## 🔧 疑難排解

### 問題：查詢返回 0

```bash
# 1. 檢查 RLS 政策
# 在 SQL Editor 執行 scripts/setup_users_rls.sql

# 2. 檢查 schema 設定
# 確認使用 Accept-Profile: chats header

# 3. 驗證表格有資料
# 在 SQL Editor: SELECT * FROM chats.users;
```

### 問題：同步失敗

```bash
# 1. 檢查觸發器
# SQL: SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

# 2. 重新執行同步
# 在 SQL Editor 執行 scripts/setup_auth_sync.sql

# 3. 手動同步
# 執行上方的「手動同步」SQL
```

### 問題：API Key 無效

```bash
# 1. 重新取得 key
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo

# 2. 更新 .env 檔案
# 編輯 .env，更新 SUPABASE_ANON_KEY 和 SUPABASE_URL

# 3. 重新載入環境變數
source .env
```

---

## 📁 檔案位置

### 腳本

- `scripts/query_auth_direct.dart` - 查詢 auth.users
- `scripts/check_users_count.dart` - 查詢 chats.users
- `scripts/verify_sync.sh` - 驗證同步狀態
- `scripts/load_env.sh` - 載入環境變數

### SQL

- `scripts/setup_users_rls.sql` - RLS 政策設定
- `scripts/setup_auth_sync.sql` - 同步機制設定

### 文件

- `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` - 完整實作流程
- `docs/AUTH_SYNC_GUIDE.md` - 同步指南
- `docs/RLS_SETUP_GUIDE.md` - RLS 設定指南
- `docs/QUICK_REFERENCE.md` - 本文件

---

## 🔑 環境變數

`.env` 檔案必須包含：

```env
SUPABASE_URL=https://dknjuzjbudprjrgdzaeo.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

---

## 🔗 重要連結

- [Supabase Dashboard](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo)
- [SQL Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql)
- [Authentication Users](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/auth/users)
- [Table Editor (chats.users)](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/editor/53607?schema=chats)

---

## ✅ 檢查清單

### 初次設定

- [ ] 連接到 Supabase 專案
- [ ] 取得並設定 API Keys
- [ ] 設定 RLS 政策
- [ ] 設定自動同步機制
- [ ] 驗證同步成功

### 日常維護

- [ ] 定期檢查同步狀態 (`./scripts/verify_sync.sh`)
- [ ] 監控用戶數量一致性
- [ ] 檢查觸發器運作正常
- [ ] 備份重要腳本和配置

---

**提示**: 將此文件加入書籤以便快速查閱！
