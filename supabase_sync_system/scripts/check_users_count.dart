import 'dart:io';
import 'dart:convert';

/// 查詢 chats.users 表格的用戶記錄數量
Future<void> main() async {
  try {
    // 從環境變數讀取 Supabase 配置
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      print('請使用以下方式執行：');
      print('  chmod +x scripts/load_env.sh');
      print('  ./scripts/load_env.sh');
      print('\n或直接設定環境變數：');
      print('  export SUPABASE_URL="your_url"');
      print('  export SUPABASE_ANON_KEY="your_key"');
      print('  dart run scripts/check_users_count.dart');
      exit(1);
    }
    
    // 建立 HTTP 客戶端
    final client = HttpClient();

    print('正在查詢 chats.users 表格的用戶數量...\n');
    print('🔍 調試資訊:');
    print('- Supabase URL: $supabaseUrl');
    print('- Schema: chats');
    print('- Table: users\n');

    // 查詢總數（使用 count）
    final countUrl = Uri.parse('$supabaseUrl/rest/v1/users?select=*&limit=0');
    final countRequest = await client.getUrl(countUrl);
    countRequest.headers.set('apikey', supabaseKey);
    countRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    countRequest.headers.set('Accept-Profile', 'chats');
    countRequest.headers.set('Content-Profile', 'chats');
    countRequest.headers.set('Prefer', 'count=exact');
    
    final countResponse = await countRequest.close();
    
    print('📡 HTTP 回應狀態: ${countResponse.statusCode}');
    
    if (countResponse.statusCode != 200) {
      final errorBody = await countResponse.transform(utf8.decoder).join();
      print('❌ 錯誤回應: $errorBody\n');
      throw Exception('HTTP ${countResponse.statusCode}: $errorBody');
    }
    
    final contentRange = countResponse.headers.value('content-range');
    print('📊 Content-Range header: $contentRange\n');
    
    final totalCount = int.tryParse(
      contentRange?.split('/').last ?? '0'
    ) ?? 0;
    
    await countResponse.drain();

    print('═══════════════════════════════════════');
    print('📊 chats.users 表格統計');
    print('═══════════════════════════════════════');
    print('總用戶數: $totalCount');
    print('═══════════════════════════════════════\n');

    // 如果有用戶，顯示前 5 筆記錄的基本資訊
    if (totalCount > 0) {
      final usersUrl = Uri.parse(
        '$supabaseUrl/rest/v1/users?select=id,first_name,last_name,created_at&limit=5'
      );
      final usersRequest = await client.getUrl(usersUrl);
      usersRequest.headers.set('apikey', supabaseKey);
      usersRequest.headers.set('Authorization', 'Bearer $supabaseKey');
      usersRequest.headers.set('Accept-Profile', 'chats');
      usersRequest.headers.set('Content-Profile', 'chats');
      
      final usersResponse = await usersRequest.close();
      final responseBody = await usersResponse.transform(utf8.decoder).join();
      final users = json.decode(responseBody) as List;

      print('前 5 筆用戶記錄:');
      print('-----------------------------------');
      
      for (var i = 0; i < users.length; i++) {
        final user = users[i] as Map<String, dynamic>;
        final firstName = user['first_name'] ?? 'N/A';
        final lastName = user['last_name'] ?? 'N/A';
        final createdAt = user['created_at'] ?? 'N/A';
        
        print('${i + 1}. ID: ${user['id']}');
        print('   姓名: $firstName $lastName');
        print('   建立時間: $createdAt');
        print('-----------------------------------');
      }
    }
    
    client.close();

    exit(0);
  } catch (e) {
    print('❌ 查詢時發生錯誤: $e');
    exit(1);
  }
}
