import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('更多')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 導航到設定頁面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('設定功能開發中')));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('關於'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 導航到關於頁面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('關於功能開發中')));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('幫助與支援'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 導航到幫助頁面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('幫助功能開發中')));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隱私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 導航到隱私政策頁面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('隱私政策功能開發中')));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('服務條款'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 導航到服務條款頁面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('服務條款功能開發中')));
            },
          ),
        ],
      ),
    );
  }
}




