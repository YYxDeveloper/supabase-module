import 'dart:io';
import 'dart:convert';

/// 檢查 RLS 政策狀態和表格資料
Future<void> main() async {
  try {
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      exit(1);
    }

    final client = HttpClient();

    print('🔍 檢查 chats.users 表格狀態...\n');

    // 1. 嘗試不使用 schema 前綴查詢
    print('測試 1: 查詢 public.users');
    await testQuery(client, supabaseUrl, supabaseKey, 'public', 'users');
    
    print('\n測試 2: 查詢 chats.users');
    await testQuery(client, supabaseUrl, supabaseKey, 'chats', 'users');
    
    print('\n測試 3: 列出所有可用的表格');
    await listTables(client, supabaseUrl, supabaseKey, 'chats');

    client.close();
    exit(0);
  } catch (e) {
    print('❌ 錯誤: $e');
    exit(1);
  }
}

Future<void> testQuery(HttpClient client, String url, String key, String schema, String table) async {
  try {
    final queryUrl = Uri.parse('$url/rest/v1/$table?select=count');
    final request = await client.getUrl(queryUrl);
    request.headers.set('apikey', key);
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('Accept-Profile', schema);
    request.headers.set('Prefer', 'count=exact');
    
    final response = await request.close();
    print('  狀態碼: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final contentRange = response.headers.value('content-range');
      print('  ✅ 成功！Content-Range: $contentRange');
    } else {
      final body = await response.transform(utf8.decoder).join();
      print('  ❌ 失敗: $body');
    }
    
    await response.drain();
  } catch (e) {
    print('  ❌ 例外: $e');
  }
}

Future<void> listTables(HttpClient client, String url, String key, String schema) async {
  try {
    // 嘗試查詢 information_schema
    final queryUrl = Uri.parse('$url/rest/v1/');
    final request = await client.getUrl(queryUrl);
    request.headers.set('apikey', key);
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('Accept-Profile', schema);
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    print('  API 根路徑回應:');
    print('  ${body.substring(0, body.length > 200 ? 200 : body.length)}...');
    
    await response.drain();
  } catch (e) {
    print('  ❌ 無法列出表格: $e');
  }
}
