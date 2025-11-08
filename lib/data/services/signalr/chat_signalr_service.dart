
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
