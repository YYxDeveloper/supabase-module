-- 查詢 chats.users 表格的 RLS 狀態和政策
-- 在 Supabase Dashboard > SQL Editor 中執行此查詢

-- 1. 檢查 RLS 是否啟用
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'chats' 
  AND tablename = 'users';

-- 2. 查看現有的 RLS 政策
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd as command,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies 
WHERE schemaname = 'chats' 
  AND tablename = 'users'
ORDER BY policyname;
