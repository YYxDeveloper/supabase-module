-- 設定 chats.users 表格的 RLS 政策
-- 在 Supabase Dashboard > SQL Editor 中執行此腳本

-- ============================================
-- 方案：允許已認證用戶讀取所有用戶資料
-- ============================================

-- 1. 確保 RLS 已啟用（如果尚未啟用）
ALTER TABLE chats.users ENABLE ROW LEVEL SECURITY;

-- 2. 刪除舊的讀取政策（如果存在）
DROP POLICY IF EXISTS "Allow authenticated users to read users" ON chats.users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON chats.users;

-- 3. 建立新的讀取政策：允許已認證用戶讀取所有用戶
CREATE POLICY "Enable read access for authenticated users" 
ON chats.users
FOR SELECT
TO authenticated
USING (true);

-- 4. （可選）如果需要允許匿名用戶也能讀取（例如公開的用戶列表功能）
-- 取消下方註解以啟用
-- DROP POLICY IF EXISTS "Enable read access for anon users" ON chats.users;
-- CREATE POLICY "Enable read access for anon users" 
-- ON chats.users
-- FOR SELECT
-- TO anon
-- USING (true);

-- ============================================
-- 其他常見的 RLS 政策範例（根據需求選用）
-- ============================================

-- 範例 1: 只允許用戶讀取自己的資料
-- DROP POLICY IF EXISTS "Users can read own data" ON chats.users;
-- CREATE POLICY "Users can read own data"
-- ON chats.users
-- FOR SELECT
-- TO authenticated
-- USING (auth.uid() = id);

-- 範例 2: 允許用戶更新自己的資料
-- DROP POLICY IF EXISTS "Users can update own data" ON chats.users;
-- CREATE POLICY "Users can update own data"
-- ON chats.users
-- FOR UPDATE
-- TO authenticated
-- USING (auth.uid() = id)
-- WITH CHECK (auth.uid() = id);

-- 範例 3: 允許新用戶插入自己的記錄
-- DROP POLICY IF EXISTS "Users can insert own data" ON chats.users;
-- CREATE POLICY "Users can insert own data"
-- ON chats.users
-- FOR INSERT
-- TO authenticated
-- WITH CHECK (auth.uid() = id);

-- ============================================
-- 驗證政策設定
-- ============================================
SELECT 
    policyname,
    cmd as command,
    roles,
    qual as using_expression
FROM pg_policies 
WHERE schemaname = 'chats' 
  AND tablename = 'users';
