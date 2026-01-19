-- 設定 chats.users 表格的 RLS 政策
-- 允許匿名用戶和已認證用戶讀取用戶資料

-- 啟用 RLS
ALTER TABLE chats.users ENABLE ROW LEVEL SECURITY;

-- 刪除舊政策（如果存在）
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
