import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'room_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _pageSize = 20;
  String _filter = '';

  final PagingController<int, types.Room> _controller = PagingController(
    firstPageKey: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setFilters(String filter) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filter = filter;
      if (mounted) {
        _controller.nextPageKey = 0;
        _controller.refresh();
      }
    });
  }

  Future<void> _fetchPage(int offset) async {
    try {
      final newItems = await SupabaseChatCore.instance.rooms(
        filter: _filter,
        offset: offset,
        limit: _pageSize,
      );
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _controller.appendLastPage(newItems);
      } else {
        final nextPageKey = offset + newItems.length;
        _controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('聊天')),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '請先登入以使用聊天功能',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '搜尋聊天室',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _setFilters(value),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _controller.nextPageKey = 0;
                          _controller.refresh();
                        }
                      });
                    },
                    child: StreamBuilder<List<types.Room>>(
                      stream: SupabaseChatCore.instance.roomsUpdates(),
                      builder: (context, snapshot) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            if (_filter == '' && snapshot.data != null) {
                              _controller.itemList =
                                  SupabaseChatCore.updateRoomList(
                                    _controller.itemList ?? [],
                                    snapshot.data!,
                                  );
                            }
                          }
                        });
                        return PagedListView<int, types.Room>(
                          pagingController: _controller,
                          builderDelegate:
                              PagedChildBuilderDelegate<types.Room>(
                                itemBuilder: (context, room, index) => ListTile(
                                  leading: CircleAvatar(
                                    child: room.imageUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              room.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.chat,
                                                    );
                                                  },
                                            ),
                                          )
                                        : const Icon(Icons.chat),
                                  ),
                                  title: Text(room.name ?? '未命名聊天室'),
                                  subtitle:
                                      room.lastMessages?.isNotEmpty == true &&
                                          room.lastMessages!.first
                                              is types.TextMessage
                                      ? Text(
                                          (room.lastMessages!.first
                                                  as types.TextMessage)
                                              .text,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : const Text('尚無訊息'),
                                  trailing: room.updatedAt != null
                                      ? Text(
                                          _formatDateTime(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              room.updatedAt!,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RoomPage(room: room),
                                      ),
                                    );
                                  },
                                ),
                                firstPageErrorIndicatorBuilder: (context) =>
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '載入失敗',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _controller.refresh(),
                                            child: const Text('重試'),
                                          ),
                                        ],
                                      ),
                                    ),
                                firstPageProgressIndicatorBuilder: (context) =>
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                newPageProgressIndicatorBuilder: (context) =>
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                noItemsFoundIndicatorBuilder: (context) =>
                                    _buildEmptyState(),
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _filter.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              _filter.isEmpty ? '尚無聊天室' : '找不到符合條件的聊天室',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _filter.isEmpty ? '開始您的第一個對話吧！' : '請嘗試其他搜尋關鍵字',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '剛剛';
        }
        return '${difference.inMinutes}分鐘前';
      }
      return '${difference.inHours}小時前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}
