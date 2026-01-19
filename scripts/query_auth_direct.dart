import 'dart:io';
import 'dart:convert';

/// 直接查詢 auth.users（使用 service_role key）
Future<void> main(List<String> args) async {
  try {
    final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 
        'https://dknjuzjbudprjrgdzaeo.supabase.co';
    
    // 從命令列參數或環境變數取得 service_role key
    final serviceRoleKey = args.isNotEmpty 
        ? args[0] 
        : Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ??
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrbmp1empidWRwcmpyZ2R6YWVvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDk0NTU1OCwiZXhwIjoyMDc2NTIxNTU4fQ._Vgun3SxerTC0tE7adnJAjNm50-hOvkGQmHVdoyBdxE';

    final client = HttpClient();

    print('🔐 正在查詢 Authentication > Users (使用 service_role)...\n');
    print('🔍 調試資訊:');
    print('- Supabase URL: $supabaseUrl');
    print('- 使用: service_role key\n');

    // 使用 Supabase Auth Admin API 查詢用戶
    final listUrl = Uri.parse('$supabaseUrl/auth/v1/admin/users');
    final listRequest = await client.getUrl(listUrl);
    listRequest.headers.set('apikey', serviceRoleKey);
    listRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    
    final listResponse = await listRequest.close();
    
    print('📡 HTTP 回應狀態: ${listResponse.statusCode}\n');
    
    if (listResponse.statusCode == 200) {
      final responseBody = await listResponse.transform(utf8.decoder).join();
      final data = json.decode(responseBody) as Map<String, dynamic>;
      final users = data['users'] as List? ?? [];
      
      print('═══════════════════════════════════════');
      print('📊 Authentication Users 統計');
      print('═══════════════════════════════════════');
      print('總用戶數: ${users.length}');
      print('═══════════════════════════════════════\n');
      
      if (users.isNotEmpty) {
        print('👥 用戶列表：\n');
        
        for (var i = 0; i < users.length; i++) {
          final user = users[i] as Map<String, dynamic>;
          final email = user['email'] ?? 'N/A';
          final createdAt = user['created_at'] ?? 'N/A';
          final lastSignIn = user['last_sign_in_at'] ?? '尚未登入';
          final confirmed = user['email_confirmed_at'] != null ? '✅' : '❌';
          
          print('${i + 1}. ID: ${user['id']}');
          print('   Email: $email');
          print('   Email 已驗證: $confirmed');
          print('   建立時間: $createdAt');
          print('   最後登入: $lastSignIn');
          
          // 顯示登入方式
          final identities = user['identities'] as List? ?? [];
          if (identities.isNotEmpty) {
            final providers = identities.map((i) => i['provider']).join(', ');
            print('   登入方式: $providers');
          }
          
          print('-----------------------------------');
        }
      }
    } else {
      final errorBody = await listResponse.transform(utf8.decoder).join();
      print('❌ 查詢失敗 (${listResponse.statusCode}):');
      print(errorBody);
    }
    
    client.close();
    exit(0);
  } catch (e) {
    print('❌ 查詢時發生錯誤: $e');
    exit(1);
  }
}
