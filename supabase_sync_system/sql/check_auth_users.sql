-- 檢查 auth.users 表格的用戶數量
-- 在 Supabase Dashboard > SQL Editor 執行

-- 查詢 auth.users（認證系統的用戶）
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- 統計數量
SELECT COUNT(*) as total_users FROM auth.users;
