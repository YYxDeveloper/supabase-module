import 'dart:io';
import 'dart:convert';

/// 查詢 auth.users 表格的用戶記錄數量（認證系統）
Future<void> main() async {
  try {
    // 從環境變數讀取 Supabase 配置
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      print('請使用: ./scripts/load_env.sh');
      exit(1);
    }

    // 建立 HTTP 客戶端
    final client = HttpClient();

    print('正在查詢 Authentication > Users (auth.users)...\n');
    print('🔍 調試資訊:');
    print('- Supabase URL: $supabaseUrl');
    print('- Schema: auth');
    print('- Table: users\n');

    // 查詢總數（使用 count）
    // 注意：auth.users 在 REST API 中通常不直接暴露，需要使用管理 API
    // 讓我們嘗試通過 RPC 或 Management API
    
    print('⚠️  auth.users 表格需要特殊權限才能查詢。');
    print('建議使用以下方式：\n');
    
    print('方法 1: 在 Supabase Dashboard SQL Editor 執行');
    print('───────────────────────────────────────');
    print('SELECT COUNT(*) FROM auth.users;');
    print('───────────────────────────────────────\n');
    
    print('方法 2: 檢查 Dashboard');
    print('前往: https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/auth/users');
    print('\n');
    
    print('方法 3: 建立 RPC 函數來查詢');
    print('───────────────────────────────────────');
    print('CREATE OR REPLACE FUNCTION get_auth_users_count()');
    print('RETURNS INTEGER');
    print('LANGUAGE plpgsql');
    print('SECURITY DEFINER');
    print('AS \$\$');
    print('BEGIN');
    print('  RETURN (SELECT COUNT(*)::INTEGER FROM auth.users);');
    print('END;');
    print('\$\$;');
    print('───────────────────────────────────────');
    
    client.close();
    
  } catch (e) {
    print('❌ 錯誤: $e');
    exit(1);
  }
}
