-- ============================================
-- Auth Users → Chats Users 自動同步設定
-- ============================================

-- 步驟 1: 建立觸發器函數 - 當 auth.users 有新用戶時自動同步到 chats.users
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
      COALESCE(NEW.raw_user_meta_data->>'first_name', split_part(NEW.email, '@', 1)), -- 從 email 前綴作為預設名稱
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

-- 步驟 2: 建立觸發器 - 監聽 auth.users 的變更
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_auth_user_to_chats();

-- 步驟 3: 同步現有用戶 - 將目前所有 auth.users 的用戶同步到 chats.users
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

-- 步驟 5: 顯示同步後的 chats.users 資料
SELECT 
  id,
  first_name,
  last_name,
  created_at
FROM chats.users
ORDER BY created_at DESC;
