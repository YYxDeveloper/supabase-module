# Supabase 用戶查詢與同步完整實作流程

## 📋 目錄

1. [問題背景](#問題背景)
2. [問題診斷](#問題診斷)
3. [解決方案架構](#解決方案架構)
4. [實作步驟](#實作步驟)
5. [代碼實作](#代碼實作)
6. [測試與驗證](#測試與驗證)
7. [維護與疑難排解](#維護與疑難排解)

---

## 問題背景

### 初始需求
查詢 Supabase 資料庫中 `chats.users` 表格的用戶數量。

### 發現的問題
1. **RLS (Row Level Security) 限制** - API 查詢受 RLS 政策阻擋
2. **表格位置混淆** - 用戶資料在 `auth.users`，不在 `chats.users`
3. **資料不同步** - `auth.users` 有 4 筆，`chats.users` 為空

---

## 問題診斷

### 診斷流程圖

```
用戶需求：查詢 chats.users 數量
    ↓
建立查詢腳本 (check_users_count.dart)
    ↓
執行查詢 → HTTP 401 (API Key 無效)
    ↓
修正：從 .env 讀取正確的 API Key
    ↓
執行查詢 → HTTP 404 (找不到 public.users)
    ↓
修正：添加 Accept-Profile: chats header
    ↓
執行查詢 → HTTP 200，但 count = 0
    ↓
診斷：RLS 政策阻擋 or 表格真的是空的？
    ↓
設定 RLS 政策允許 anon 讀取
    ↓
再次查詢 → 確認表格真的是空的
    ↓
發現：用戶資料在 auth.users (4 筆)
    ↓
解決方案：建立自動同步機制
```

### 關鍵診斷命令

```bash
# 1. 檢查 Supabase 專案連接
supabase projects list

# 2. 連接到專案
supabase link --project-ref dknjuzjbudprjrgdzaeo

# 3. 取得 API Keys
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo

# 4. 查詢 auth.users (使用 service_role key)
dart run scripts/query_auth_direct.dart
```

---

## 解決方案架構

### 架構圖

```
┌─────────────────────────────────────────────────────────┐
│                    Supabase Platform                    │
│                                                         │
│  ┌────────────────┐          ┌────────────────┐       │
│  │  auth.users    │          │  chats.users   │       │
│  │  (認證系統)     │  ─sync→  │  (聊天系統)     │       │
│  │                │          │                │       │
│  │  - id          │          │  - id          │       │
│  │  - email       │          │  - first_name  │       │
│  │  - metadata    │          │  - last_name   │       │
│  │  - created_at  │          │  - created_at  │       │
│  └────────────────┘          └────────────────┘       │
│         │                             ▲                │
│         │                             │                │
│         └──── Trigger Function ───────┘                │
│              (auto sync on INSERT/UPDATE)              │
└─────────────────────────────────────────────────────────┘
         │                             │
         ▼                             ▼
    Admin API                     REST API
    (service_role)                (anon key)
         │                             │
         ▼                             ▼
┌─────────────────┐          ┌─────────────────┐
│  查詢腳本         │          │  同步腳本         │
│  (Dart)         │          │  (SQL + Dart)   │
└─────────────────┘          └─────────────────┘
```

### 解決方案組件

1. **查詢工具**
   - `query_auth_direct.dart` - 查詢 `auth.users`
   - `check_users_count.dart` - 查詢 `chats.users`
   - `verify_sync.sh` - 驗證同步狀態

2. **同步機制**
   - `setup_auth_sync.sql` - 建立觸發器和同步現有資料
   - Trigger Function - 自動同步新用戶

3. **RLS 政策**
   - `setup_users_rls.sql` - 設定 `chats.users` 讀取權限

---

## 實作步驟

### Phase 1: 環境設定與初步查詢

#### 步驟 1.1: 建立查詢腳本

**檔案**: `scripts/check_users_count.dart`

```dart
import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  try {
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      exit(1);
    }

    final client = HttpClient();

    print('正在查詢 chats.users 表格的用戶數量...\n');

    // 查詢總數
    final countUrl = Uri.parse('$supabaseUrl/rest/v1/users?select=*&limit=0');
    final countRequest = await client.getUrl(countUrl);
    countRequest.headers.set('apikey', supabaseKey);
    countRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    countRequest.headers.set('Accept-Profile', 'chats');
    countRequest.headers.set('Content-Profile', 'chats');
    countRequest.headers.set('Prefer', 'count=exact');
    
    final countResponse = await countRequest.close();
    
    if (countResponse.statusCode != 200) {
      final errorBody = await countResponse.transform(utf8.decoder).join();
      throw Exception('HTTP ${countResponse.statusCode}: $errorBody');
    }
    
    final totalCount = int.tryParse(
      countResponse.headers.value('content-range')?.split('/').last ?? '0'
    ) ?? 0;

    print('═══════════════════════════════════════');
    print('📊 chats.users 表格統計');
    print('═══════════════════════════════════════');
    print('總用戶數: $totalCount');
    print('═══════════════════════════════════════\n');

    client.close();
    exit(0);
  } catch (e) {
    print('❌ 查詢時發生錯誤: $e');
    exit(1);
  }
}
```

#### 步驟 1.2: 建立環境變數載入腳本

**檔案**: `scripts/load_env.sh`

```bash
#!/bin/bash
# 載入 .env 檔案並執行 Dart 腳本

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ 已載入 .env 檔案"
else
    echo "❌ 找不到 .env 檔案"
    exit 1
fi

dart run scripts/check_users_count.dart
```

#### 步驟 1.3: 執行查詢

```bash
# 賦予執行權限
chmod +x scripts/load_env.sh

# 執行查詢
./scripts/load_env.sh
```

**預期輸出**:
```
✅ 已載入 .env 檔案
正在查詢 chats.users 表格的用戶數量...

═══════════════════════════════════════
📊 chats.users 表格統計
═══════════════════════════════════════
總用戶數: 0
═══════════════════════════════════════
```

---

### Phase 2: RLS 政策設定

#### 步驟 2.1: 建立 RLS 設定 SQL

**檔案**: `scripts/setup_users_rls.sql`

```sql
-- 啟用 RLS
ALTER TABLE chats.users ENABLE ROW LEVEL SECURITY;

-- 刪除舊政策
DROP POLICY IF EXISTS "Enable read access for anon users" ON chats.users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON chats.users;

-- 建立新政策：允許匿名用戶讀取
CREATE POLICY "Enable read access for anon users" 
ON chats.users 
FOR SELECT 
TO anon 
USING (true);

-- 建立新政策：允許已認證用戶讀取
CREATE POLICY "Enable read access for authenticated users" 
ON chats.users 
FOR SELECT 
TO authenticated 
USING (true);
```

#### 步驟 2.2: 執行 RLS 設定

```bash
# 複製 SQL 到剪貼簿
pbcopy < scripts/setup_users_rls.sql

# 手動操作：
# 1. 前往 https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql
# 2. 貼上並執行 SQL
```

---

### Phase 3: 查詢 Authentication Users

#### 步驟 3.1: 取得 API Keys

```bash
cd /Users/qw/YYx/subabase_park

# 列出專案
supabase projects list

# 連接專案
supabase link --project-ref dknjuzjbudprjrgdzaeo

# 取得 API Keys
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo
```

**輸出**:
```
NAME         | KEY VALUE
-------------|----------------------------------------------------------
anon         | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 步驟 3.2: 建立 Auth Users 查詢腳本

**檔案**: `scripts/query_auth_direct.dart`

```dart
import 'dart:io';
import 'dart:convert';

Future<void> main(List<String> args) async {
  try {
    final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 
        'https://dknjuzjbudprjrgdzaeo.supabase.co';
    
    final serviceRoleKey = args.isNotEmpty 
        ? args[0] 
        : Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ??
          'YOUR_SERVICE_ROLE_KEY';

    final client = HttpClient();

    print('🔐 正在查詢 Authentication > Users...\n');

    // 使用 Supabase Auth Admin API
    final listUrl = Uri.parse('$supabaseUrl/auth/v1/admin/users');
    final listRequest = await client.getUrl(listUrl);
    listRequest.headers.set('apikey', serviceRoleKey);
    listRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    
    final listResponse = await listRequest.close();
    
    if (listResponse.statusCode == 200) {
      final responseBody = await listResponse.transform(utf8.decoder).join();
      final data = json.decode(responseBody) as Map<String, dynamic>;
      final users = data['users'] as List? ?? [];
      
      print('═══════════════════════════════════════');
      print('📊 Authentication Users 統計');
      print('═══════════════════════════════════════');
      print('總用戶數: ${users.length}');
      print('═══════════════════════════════════════\n');
      
      if (users.isNotEmpty) {
        print('👥 用戶列表：\n');
        
        for (var i = 0; i < users.length; i++) {
          final user = users[i] as Map<String, dynamic>;
          final email = user['email'] ?? 'N/A';
          final createdAt = user['created_at'] ?? 'N/A';
          final lastSignIn = user['last_sign_in_at'] ?? '尚未登入';
          final confirmed = user['email_confirmed_at'] != null ? '✅' : '❌';
          
          print('${i + 1}. ID: ${user['id']}');
          print('   Email: $email');
          print('   Email 已驗證: $confirmed');
          print('   建立時間: $createdAt');
          print('   最後登入: $lastSignIn');
          print('-----------------------------------');
        }
      }
    } else {
      final errorBody = await listResponse.transform(utf8.decoder).join();
      print('❌ 查詢失敗: $errorBody');
    }
    
    client.close();
    exit(0);
  } catch (e) {
    print('❌ 錯誤: $e');
    exit(1);
  }
}
```

#### 步驟 3.3: 執行查詢

```bash
dart run scripts/query_auth_direct.dart
```

**輸出**:
```
🔐 正在查詢 Authentication > Users...

═══════════════════════════════════════
📊 Authentication Users 統計
═══════════════════════════════════════
總用戶數: 4
═══════════════════════════════════════

👥 用戶列表：

1. ID: 01a73a77-7a79-4379-9d20-ca75996be003
   Email: downlolow@gmail.com
   Email 已驗證: ✅
   建立時間: 2026-01-19T12:58:44.168658Z
   最後登入: 2026-01-19T12:58:44.223328Z
-----------------------------------
[... 其他 3 筆用戶 ...]
```

---

### Phase 4: 自動同步機制

#### 步驟 4.1: 建立同步 SQL

**檔案**: `scripts/setup_auth_sync.sql`

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
  -- 當 auth.users 新增用戶時，同步到 chats.users
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO chats.users (
      id,
      first_name,
      last_name,
      created_at,
      updated_at
    )
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'first_name', split_part(NEW.email, '@', 1)),
      COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
      NEW.created_at,
      NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
      updated_at = NOW();
    
    RETURN NEW;
  END IF;
  
  -- 當 auth.users 更新用戶時，也更新 chats.users
  IF (TG_OP = 'UPDATE') THEN
    UPDATE chats.users
    SET
      first_name = COALESCE(NEW.raw_user_meta_data->>'first_name', first_name),
      last_name = COALESCE(NEW.raw_user_meta_data->>'last_name', last_name),
      updated_at = NOW()
    WHERE id = NEW.id;
    
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$;

-- 步驟 2: 建立觸發器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_auth_user_to_chats();

-- 步驟 3: 同步現有用戶
INSERT INTO chats.users (
  id,
  first_name,
  last_name,
  created_at,
  updated_at
)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'first_name', split_part(au.email, '@', 1)) as first_name,
  COALESCE(au.raw_user_meta_data->>'last_name', '') as last_name,
  au.created_at,
  NOW() as updated_at
FROM auth.users au
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = EXCLUDED.updated_at;

-- 步驟 4: 驗證同步結果
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

#### 步驟 4.2: 執行同步

```bash
# 複製 SQL 到剪貼簿
pbcopy < scripts/setup_auth_sync.sql

# 手動操作：
# 1. 前往 https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql
# 2. 貼上並執行 SQL
```

**預期輸出** (在 SQL Editor):
```
source       | count
-------------|------
auth.users   | 4
chats.users  | 4
```

---

### Phase 5: 驗證同步

#### 步驟 5.1: 建立驗證腳本

**檔案**: `scripts/verify_sync.sh`

```bash
#!/bin/bash

echo "🔄 驗證 Auth Users 同步狀態..."
echo ""

# 載入環境變數
export $(cat .env | grep -v '^#' | xargs)

echo "1️⃣ 查詢 auth.users 數量..."
dart run scripts/query_auth_direct.dart > /tmp/auth_count.txt 2>&1
AUTH_COUNT=$(grep "總用戶數:" /tmp/auth_count.txt | grep -oE '[0-9]+')
echo "   auth.users: $AUTH_COUNT 筆"

echo ""
echo "2️⃣ 查詢 chats.users 數量..."
dart run scripts/check_users_count.dart > /tmp/chats_count.txt 2>&1
CHATS_COUNT=$(grep "總用戶數:" /tmp/chats_count.txt | grep -oE '[0-9]+')
echo "   chats.users: $CHATS_COUNT 筆"

echo ""
echo "═══════════════════════════════════════"
if [ "$AUTH_COUNT" = "$CHATS_COUNT" ]; then
    echo "✅ 同步成功！兩個表格的用戶數量一致"
else
    echo "⚠️  用戶數量不一致"
    echo "   auth.users:  $AUTH_COUNT"
    echo "   chats.users: $CHATS_COUNT"
fi
echo "═══════════════════════════════════════"
```

#### 步驟 5.2: 執行驗證

```bash
# 賦予執行權限
chmod +x scripts/verify_sync.sh

# 執行驗證
./scripts/verify_sync.sh
```

**預期輸出**:
```
🔄 驗證 Auth Users 同步狀態...

1️⃣ 查詢 auth.users 數量...
   auth.users: 4 筆

2️⃣ 查詢 chats.users 數量...
   chats.users: 4 筆

═══════════════════════════════════════
✅ 同步成功！兩個表格的用戶數量一致
═══════════════════════════════════════
```

---

## 代碼實作

### 核心組件說明

#### 1. HTTP 請求處理 (Dart)

```dart
// 基本 HTTP GET 請求模式
final client = HttpClient();
final url = Uri.parse('$baseUrl/rest/v1/table_name');
final request = await client.getUrl(url);

// 設定必要的 headers
request.headers.set('apikey', key);
request.headers.set('Authorization', 'Bearer $key');
request.headers.set('Accept-Profile', 'schema_name');  // 指定 schema
request.headers.set('Prefer', 'count=exact');          // 要求精確計數

final response = await request.close();

// 處理回應
if (response.statusCode == 200) {
  final body = await response.transform(utf8.decoder).join();
  final data = json.decode(body);
  // 處理資料
}
```

#### 2. Supabase REST API Schema 指定

```dart
// 錯誤方式 - 會查詢 public schema
request.headers.set('Content-Profile', 'chats');  // 只用於寫入

// 正確方式 - 查詢 chats schema
request.headers.set('Accept-Profile', 'chats');   // 用於讀取
request.headers.set('Content-Profile', 'chats');  // 用於寫入
```

#### 3. PostgreSQL Trigger 函數模式

```sql
CREATE OR REPLACE FUNCTION schema.function_name()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER              -- 以函數擁有者權限執行
SET search_path = public      -- 設定 schema 搜尋路徑
AS $$
BEGIN
  -- INSERT 事件處理
  IF (TG_OP = 'INSERT') THEN
    -- 插入邏輯
    RETURN NEW;
  END IF;
  
  -- UPDATE 事件處理
  IF (TG_OP = 'UPDATE') THEN
    -- 更新邏輯
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$;

-- 建立觸發器
CREATE TRIGGER trigger_name
  AFTER INSERT OR UPDATE ON source_table
  FOR EACH ROW
  EXECUTE FUNCTION schema.function_name();
```

#### 4. 環境變數處理 (Bash)

```bash
# 載入 .env 檔案
export $(cat .env | grep -v '^#' | xargs)

# 或使用 source (在某些 shell 中)
source .env

# 傳遞給 Dart
dart run script.dart
```

---

## 測試與驗證

### 測試清單

#### ✅ 基本查詢測試

```bash
# 測試 1: 查詢 chats.users
./scripts/load_env.sh

# 預期：顯示用戶數量（同步後應為 4）
```

#### ✅ Auth Users 查詢測試

```bash
# 測試 2: 查詢 auth.users
dart run scripts/query_auth_direct.dart

# 預期：顯示 4 筆用戶詳細資訊
```

#### ✅ 同步驗證測試

```bash
# 測試 3: 驗證同步
./scripts/verify_sync.sh

# 預期：兩個表格數量一致
```

#### ✅ 新用戶自動同步測試

**在 Supabase Dashboard 手動測試**:

1. 前往 Authentication > Users
2. 建立新用戶
3. 執行查詢腳本驗證 `chats.users` 也有新記錄

**或使用 SQL**:

```sql
-- 模擬新用戶註冊
INSERT INTO auth.users (
  instance_id,
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'test@example.com',
  crypt('password123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW()
);

-- 驗證是否同步到 chats.users
SELECT * FROM chats.users WHERE email = 'test@example.com';
```

---

## 維護與疑難排解

### 常見問題

#### 問題 1: API Key 無效 (HTTP 401)

**症狀**:
```
HTTP 回應狀態: 401
❌ 錯誤: Invalid API key
```

**解決方法**:
```bash
# 1. 檢查 .env 檔案
cat .env | grep SUPABASE

# 2. 重新取得正確的 key
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo

# 3. 更新 .env 檔案
```

#### 問題 2: 找不到表格 (HTTP 404)

**症狀**:
```
HTTP 回應狀態: 404
Could not find the table 'public.users'
```

**解決方法**:
```dart
// 確保設定正確的 schema
request.headers.set('Accept-Profile', 'chats');  // 不是 public
```

#### 問題 3: RLS 政策阻擋 (count = 0)

**症狀**:
```
HTTP 回應狀態: 200
Content-Range: */0
總用戶數: 0
```

**診斷**:
```sql
-- 檢查 RLS 是否啟用
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'chats' AND tablename = 'users';

-- 檢查政策
SELECT * FROM pg_policies 
WHERE schemaname = 'chats' AND tablename = 'users';
```

**解決方法**:
執行 `scripts/setup_users_rls.sql`

#### 問題 4: 觸發器未執行

**症狀**:
新用戶註冊後，`chats.users` 沒有新記錄

**診斷**:
```sql
-- 檢查觸發器
SELECT * FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- 檢查函數
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'sync_auth_user_to_chats';
```

**解決方法**:
重新執行 `scripts/setup_auth_sync.sql`

#### 問題 5: Migration 歷史不同步

**症狀**:
```
Remote migration versions not found in local migrations
```

**解決方法**:
```bash
# 修復 migration 狀態
supabase migration repair --status reverted 20251020111402
supabase migration repair --status applied 20260119154150

# 或重新連接專案
supabase link --project-ref dknjuzjbudprjrgdzaeo
```

### 監控與日誌

#### 監控同步狀態

**建立監控查詢**:

```sql
-- 每日監控腳本
WITH auth_count AS (
  SELECT COUNT(*) as cnt FROM auth.users
),
chats_count AS (
  SELECT COUNT(*) as cnt FROM chats.users
)
SELECT 
  a.cnt as auth_users,
  c.cnt as chats_users,
  CASE 
    WHEN a.cnt = c.cnt THEN '✅ 同步正常'
    ELSE '⚠️ 數量不一致'
  END as status
FROM auth_count a, chats_count c;
```

#### 查看觸發器執行記錄

```sql
-- 檢查最近更新的 chats.users 記錄
SELECT 
  id,
  first_name,
  last_name,
  created_at,
  updated_at,
  updated_at - created_at as sync_delay
FROM chats.users
ORDER BY updated_at DESC
LIMIT 10;
```

### 效能考量

#### 1. 批量同步優化

如果需要同步大量用戶（>1000 筆）:

```sql
-- 使用批次處理
DO $$
DECLARE
  batch_size INT := 100;
  offset_val INT := 0;
  total_users INT;
BEGIN
  SELECT COUNT(*) INTO total_users FROM auth.users;
  
  WHILE offset_val < total_users LOOP
    INSERT INTO chats.users (id, first_name, last_name, created_at, updated_at)
    SELECT 
      au.id,
      COALESCE(au.raw_user_meta_data->>'first_name', split_part(au.email, '@', 1)),
      COALESCE(au.raw_user_meta_data->>'last_name', ''),
      au.created_at,
      NOW()
    FROM auth.users au
    ORDER BY au.created_at
    LIMIT batch_size OFFSET offset_val
    ON CONFLICT (id) DO UPDATE SET
      updated_at = EXCLUDED.updated_at;
    
    offset_val := offset_val + batch_size;
    RAISE NOTICE 'Processed % users', offset_val;
  END LOOP;
END $$;
```

#### 2. 索引優化

```sql
-- 為常用查詢欄位建立索引
CREATE INDEX IF NOT EXISTS idx_chats_users_created_at 
ON chats.users(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chats_users_updated_at 
ON chats.users(updated_at DESC);
```

---

## 總結

### 完整執行順序

```bash
# 1. 設定專案
supabase link --project-ref dknjuzjbudprjrgdzaeo

# 2. 取得 API Keys
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo

# 3. 設定 RLS 政策（在 Dashboard SQL Editor）
# 執行 scripts/setup_users_rls.sql

# 4. 查詢 auth.users
dart run scripts/query_auth_direct.dart

# 5. 設定自動同步（在 Dashboard SQL Editor）
# 執行 scripts/setup_auth_sync.sql

# 6. 驗證同步
./scripts/verify_sync.sh

# 7. 查詢 chats.users（應該有 4 筆）
./scripts/load_env.sh
```

### 關鍵學習

1. **Schema 指定很重要** - 使用 `Accept-Profile` header
2. **RLS 政策會影響查詢** - 需要適當的政策設定
3. **Auth 和 Chat 是分離的** - 需要同步機制
4. **Trigger 函數很強大** - 可以自動化資料同步
5. **Service Role Key 權限更高** - 可以繞過 RLS

### 專案結構

```
subabase_park/
├── .env                           # 環境變數
├── scripts/
│   ├── check_users_count.dart     # 查詢 chats.users
│   ├── query_auth_direct.dart     # 查詢 auth.users
│   ├── load_env.sh                # 環境變數載入
│   ├── verify_sync.sh             # 驗證同步
│   ├── setup_users_rls.sql        # RLS 政策設定
│   └── setup_auth_sync.sql        # 同步設定
├── docs/
│   ├── AUTH_SYNC_GUIDE.md         # 同步指南
│   ├── RLS_SETUP_GUIDE.md         # RLS 指南
│   └── SUPABASE_USER_QUERY_AND_SYNC_FLOW.md  # 本文件
└── supabase/
    └── migrations/
        └── 20260119154150_setup_chats_users_rls.sql
```

### 維護檢查清單

- [ ] 每週檢查同步狀態 (`./scripts/verify_sync.sh`)
- [ ] 監控觸發器執行狀況
- [ ] 定期檢查 RLS 政策
- [ ] 備份重要的同步腳本
- [ ] 文件更新（當架構變更時）

---

**文件版本**: 1.0  
**最後更新**: 2026-01-19  
**作者**: AI Assistant  
**專案**: Supabase User Query and Sync System
