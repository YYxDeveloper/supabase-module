import 'dart:io';
import 'dart:convert';

/// 透過 RPC 函數查詢 auth.users 的用戶數量
Future<void> main() async {
  try {
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ 錯誤：未設定環境變數');
      exit(1);
    }

    final client = HttpClient();

    print('正在查詢 Authentication > Users (透過 RPC)...\n');

    // 1. 查詢用戶總數
    print('📊 查詢用戶總數...');
    final countUrl = Uri.parse('$supabaseUrl/rest/v1/rpc/get_auth_users_count');
    final countRequest = await client.postUrl(countUrl);
    countRequest.headers.set('apikey', supabaseKey);
    countRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    countRequest.headers.set('Content-Type', 'application/json');
    countRequest.write('{}');
    
    final countResponse = await countRequest.close();
    
    if (countResponse.statusCode == 200) {
      final countBody = await countResponse.transform(utf8.decoder).join();
      final totalUsers = int.tryParse(countBody) ?? 0;
      
      print('═══════════════════════════════════════');
      print('📊 Authentication Users 統計');
      print('═══════════════════════════════════════');
      print('總用戶數: $totalUsers');
      print('═══════════════════════════════════════\n');
      
      // 2. 如果有用戶，查詢用戶列表
      if (totalUsers > 0) {
        print('👥 查詢用戶列表（前 5 筆）...\n');
        
        final listUrl = Uri.parse('$supabaseUrl/rest/v1/rpc/get_auth_users_list');
        final listRequest = await client.postUrl(listUrl);
        listRequest.headers.set('apikey', supabaseKey);
        listRequest.headers.set('Authorization', 'Bearer $supabaseKey');
        listRequest.headers.set('Content-Type', 'application/json');
        listRequest.write('{"limit_count": 5}');
        
        final listResponse = await listRequest.close();
        
        if (listResponse.statusCode == 200) {
          final listBody = await listResponse.transform(utf8.decoder).join();
          final users = json.decode(listBody) as List;
          
          print('前 ${users.length} 筆用戶記錄:');
          print('-----------------------------------');
          
          for (var i = 0; i < users.length; i++) {
            final user = users[i] as Map<String, dynamic>;
            final email = user['email'] ?? 'N/A';
            final createdAt = user['created_at'] ?? 'N/A';
            final lastSignIn = user['last_sign_in_at'] ?? '尚未登入';
            
            print('${i + 1}. ID: ${user['id']}');
            print('   Email: $email');
            print('   建立時間: $createdAt');
            print('   最後登入: $lastSignIn');
            print('-----------------------------------');
          }
        } else {
          final errorBody = await listResponse.transform(utf8.decoder).join();
          print('❌ 查詢用戶列表失敗: $errorBody');
        }
      }
    } else {
      final errorBody = await countResponse.transform(utf8.decoder).join();
      print('❌ 錯誤 (${countResponse.statusCode}): $errorBody');
      print('\n⚠️  請先在 SQL Editor 執行 create_auth_users_rpc.sql');
      print('   已經複製到剪貼簿，前往執行：');
      print('   https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql');
    }
    
    client.close();
    exit(0);
  } catch (e) {
    print('❌ 查詢時發生錯誤: $e');
    exit(1);
  }
}
