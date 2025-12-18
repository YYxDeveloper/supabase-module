import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:image_picker/image_picker.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  final types.Room room;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool _isAttachmentUploading = false;
  late SupabaseChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = SupabaseChatController(room: widget.room);
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('照片'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('檔案'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('取消'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      try {
        await SupabaseChatCore.instance.sendMessage(
          types.PartialFile(
            name: result.files.single.name,
            size: result.files.single.size,
            uri: result.files.single.path!,
          ),
          widget.room.id,
        );
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      try {
        await SupabaseChatCore.instance.sendMessage(
          types.PartialImage(
            name: result.name,
            size: await result.length(),
            uri: result.path,
          ),
          widget.room.id,
        );
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      // 處理檔案下載或開啟
      // 這裡可以實作檔案下載或開啟的邏輯
    }
  }

  Future<void> _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) async {
    final updatedMessage = message.copyWith(previewData: previewData);

    await SupabaseChatCore.instance.updateMessage(
      updatedMessage,
      widget.room.id,
    );
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    await _chatController.endTyping();
    await SupabaseChatCore.instance.sendMessage(message, widget.room.id);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(widget.room.name ?? '聊天室'),
    ),
    body: StreamBuilder<List<types.Message>>(
      initialData: const [],
      stream: _chatController.messages,
      builder: (context, messages) => StreamBuilder<List<types.User>>(
        initialData: const [],
        stream: _chatController.typingUsers,
        builder: (context, users) => Chat(
          showUserNames: true,
          showUserAvatars: true,
          theme: const DefaultChatTheme(messageMaxWidth: 600),
          typingIndicatorOptions: TypingIndicatorOptions(
            typingUsers: users.data ?? [],
          ),
          isAttachmentUploading: _isAttachmentUploading,
          messages: messages.data ?? [],
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: SupabaseChatCore.instance.loggedUser!,
          imageHeaders: SupabaseChatCore.instance.httpSupabaseHeaders,
          onMessageVisibilityChanged: (message, visible) async {
            if (message.status != types.Status.seen &&
                message.author.id !=
                    SupabaseChatCore.instance.loggedSupabaseUser!.id) {
              await SupabaseChatCore.instance.updateMessage(
                message.copyWith(status: types.Status.seen),
                widget.room.id,
              );
            }
          },
          onEndReached: _chatController.loadPreviousMessages,
          inputOptions: InputOptions(
            enabled: true,
            onTextChanged: (text) => _chatController.onTyping(),
          ),
        ),
      ),
    ),
  );
}
