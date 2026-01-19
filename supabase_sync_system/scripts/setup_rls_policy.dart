import 'dart:io';
import 'dart:convert';

/// 使用 Supabase API 設定 RLS 政策
Future<void> main() async {
  try {
    // 從環境變數讀取 Supabase 配置
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      exit(1);
    }

    print('🔧 正在設定 chats.users 的 RLS 政策...\n');

    // 建立 HTTP 客戶端
    final client = HttpClient();

    // SQL 語句：設定 RLS 政策
    final sqlStatements = [
      'ALTER TABLE chats.users ENABLE ROW LEVEL SECURITY;',
      'DROP POLICY IF EXISTS "Enable read access for anon users" ON chats.users;',
      'CREATE POLICY "Enable read access for anon users" ON chats.users FOR SELECT TO anon USING (true);',
      'DROP POLICY IF EXISTS "Enable read access for authenticated users" ON chats.users;',
      'CREATE POLICY "Enable read access for authenticated users" ON chats.users FOR SELECT TO authenticated USING (true);',
    ];

    print('📋 將執行以下 SQL 語句：');
    for (var i = 0; i < sqlStatements.length; i++) {
      print('${i + 1}. ${sqlStatements[i]}');
    }
    print('');

    // 使用 PostgREST RPC 功能執行 SQL
    // 注意：這需要在 Supabase 中建立一個 RPC 函數，或使用其他方法
    
    print('⚠️  注意：使用 API 執行 DDL 語句需要特殊權限。');
    print('');
    print('建議方式：');
    print('1. 前往 Supabase Dashboard SQL Editor');
    print('2. 執行 scripts/setup_users_rls.sql 中的 SQL');
    print('');
    print('或使用 Supabase CLI：');
    print('  supabase db execute --file scripts/setup_users_rls.sql');
    print('');
    
    client.close();
    
  } catch (e) {
    print('❌ 錯誤: $e');
    exit(1);
  }
}
