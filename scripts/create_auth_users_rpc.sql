-- 建立 RPC 函數來查詢 auth.users 的用戶數量和資訊
-- 在 Supabase Dashboard > SQL Editor 執行

-- 1. 建立函數：取得認證用戶數量
CREATE OR REPLACE FUNCTION public.get_auth_users_count()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (SELECT COUNT(*)::INTEGER FROM auth.users);
END;
$$;

-- 2. 建立函數：取得認證用戶列表（基本資訊）
CREATE OR REPLACE FUNCTION public.get_auth_users_list(
  limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  email TEXT,
  created_at TIMESTAMPTZ,
  last_sign_in_at TIMESTAMPTZ,
  email_confirmed_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.email,
    u.created_at,
    u.last_sign_in_at,
    u.email_confirmed_at
  FROM auth.users u
  ORDER BY u.created_at DESC
  LIMIT limit_count;
END;
$$;

-- 3. 授予執行權限給 anon 和 authenticated 角色
GRANT EXECUTE ON FUNCTION public.get_auth_users_count() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_users_list(INTEGER) TO anon, authenticated;

-- 4. 測試函數
SELECT public.get_auth_users_count() as total_users;
SELECT * FROM public.get_auth_users_list(5);
