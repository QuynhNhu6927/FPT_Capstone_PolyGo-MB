
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../core/config/api_constants.dart';

class ChatSignalrService {
  static final ChatSignalrService _instance = ChatSignalrService._internal();
  factory ChatSignalrService() => _instance;
  ChatSignalrService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  // Stream để mọi widget listen
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> initHub() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) return;

    final hubUrl = '${ApiConstants.baseUrl}/chatHub';
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      HttpConnectionOptions(
        accessTokenFactory: () async {
          final prefs = await SharedPreferences.getInstance();
          return prefs.getString('token') ?? '';
        },
      ),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('ReceiveMessage', (args) {
      if (args != null && args.isNotEmpty) {
        final data = Map<String, dynamic>.from(args[0]);
        _messageController.add(data);
      }
    });

    _hubConnection!.onclose((error) {
      _isConnected = false;
      _startReconnect();
    });

    await _hubConnection!.start();
    _isConnected = true;
  }

  void _startReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_hubConnection == null) return;
      if (_hubConnection!.state != HubConnectionState.connected) {
        try {
          debugPrint('[SignalR] Thử reconnect...');
          await _hubConnection!.start();
          _isConnected = true;
          debugPrint('[SignalR] Reconnect thành công');
          timer.cancel();
        } catch (e) {
          debugPrint('[SignalR] Reconnect thất bại: $e');
        }
      } else {
        _isConnected = true;
        timer.cancel();
      }
    });
  }

  Future<void> joinConversation(String conversationId) async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke('JoinConversation', args: [conversationId]);
        debugPrint('[SignalR] Đã join conversation $conversationId');
      } catch (e) {
        debugPrint('[SignalR] Lỗi join conversation $conversationId: $e');
      }
    } else {
      debugPrint('[SignalR] Không thể join, hub chưa kết nối');
    }
  }

  Future<void> sendTextMessage({required String conversationId, required String senderId, required String content}) async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.connected) {
      await _hubConnection!.invoke('SendTextMessage', args: [conversationId, senderId, content]);
    }
  }

  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  }) async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke(
          'MarkAsRead',
          args: [conversationId, userId],
        );
        debugPrint('[SignalR] MarkAsRead sent for conversation $conversationId by user $userId');
      } catch (e) {
        debugPrint('[SignalR] Error sending MarkAsRead: $e');
      }
    } else {
      debugPrint('[SignalR] Cannot mark as read, hub not connected');
    }
  }

  Future<void> deleteMessage({
    required String messageId,
  }) async {
    if (_hubConnection == null || _hubConnection!.state != HubConnectionState.connected) {
      debugPrint('[SignalR] Hub chưa kết nối, không thể xóa message');
      return;
    }

    try {
      // Gọi backend DeleteMessage
      await _hubConnection!.invoke('DeleteMessage', args: [messageId]);
      debugPrint('[SignalR] Yêu cầu xóa message thành công: $messageId');

      // Phát event cho các widget lắng nghe (Stream)
      _messageController.add({
        'type': 'deleted',
        'messageId': messageId,
      });
    } catch (e) {
      debugPrint('[SignalR] Lỗi khi xóa message: $e');
    }
  }

  Future<void> sendAudioMessage({
    required String conversationId,
    required String senderId,
    required String audioUrl,
  }) async {
    if (_hubConnection == null || _hubConnection!.state != HubConnectionState.connected) {
      debugPrint('[SignalR] Hub chưa kết nối, không thể gửi audio');
      return;
    }

    if (audioUrl.isEmpty) {
      debugPrint('[SignalR] Audio URL rỗng, không gửi audio');
      return;
    }

    try {
      debugPrint('[SignalR] Gửi audio message:');
      debugPrint('ConversationId: $conversationId');
      debugPrint('SenderId: $senderId');
      debugPrint('Audio URL: $audioUrl');

      await _hubConnection!.invoke(
        'SendAudioMessage',
        args: [conversationId, senderId, audioUrl],
      );

      debugPrint('[SignalR] Gửi audio message thành công');
    } catch (e) {
      debugPrint('[SignalR] Lỗi gửi audio message: $e');
    }
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required List<String> imageUrls,
  }) async {
    if (_hubConnection == null ||
        _hubConnection!.state != HubConnectionState.connected) {
      debugPrint('[SignalR] Hub chưa kết nối, không thể gửi image');
      return;
    }

    if (imageUrls.isEmpty) {
      debugPrint('[SignalR] Danh sách ảnh rỗng, không gửi image');
      return;
    }

    try {
      debugPrint('[SignalR] Gửi image message:');
      debugPrint('ConversationId: $conversationId');
      debugPrint('SenderId: $senderId');
      debugPrint('Image URLs: $imageUrls');

      await _hubConnection!.invoke(
        'SendImageMessage',
        args: [
          conversationId,
          senderId,
          imageUrls,
        ],
      );

      debugPrint('[SignalR] Gửi image message thành công: ${imageUrls.length} ảnh');

    } catch (e) {
      debugPrint('[SignalR] Lỗi gửi image message: $e');
    }
  }


  Future<void> stop() async {
    _reconnectTimer?.cancel();
    await _hubConnection?.stop();
  }

  bool get isConnected => _isConnected;
}

class ChatHubManager extends StatefulWidget {
  final Widget child;
  const ChatHubManager({required this.child, super.key});

  @override
  State<ChatHubManager> createState() => _ChatHubManagerState();
}

class _ChatHubManagerState extends State<ChatHubManager> with WidgetsBindingObserver {
  bool _hubStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndStartHub();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (ChatSignalrService().isConnected) {
        ChatSignalrService().stop();
        _hubStarted = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkAndStartHub();
    }
  }

  Future<void> _checkAndStartHub() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Nếu hub đang chạy mà login lại
    if (_hubStarted) {
      await ChatSignalrService().stop();
      _hubStarted = false;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (token != null && !_hubStarted) {
      await ChatSignalrService().initHub();
      _hubStarted = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ChatSignalrService().isConnected) {
      ChatSignalrService().stop();
      _hubStarted = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
