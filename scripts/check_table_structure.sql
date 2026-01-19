-- 檢查 chats.users 表格結構
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'chats' 
  AND table_name = 'users'
ORDER BY ordinal_position;
