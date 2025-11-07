// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:signalr_core/signalr_core.dart';
// import '../../../core/config/api_constants.dart';
//
// typedef OnReceiveMessage = void Function(Map<String, dynamic> data);
//
// class ChatSignalrService {
//   // Singleton
//   static final ChatSignalrService _instance = ChatSignalrService._internal();
//   factory ChatSignalrService() => _instance;
//   ChatSignalrService._internal();
//
//   HubConnection? _hubConnection;
//   bool _isConnected = false;
//   OnReceiveMessage? _onReceiveMessage;
//   Timer? _reconnectTimer;
//
//   /// Khởi tạo hub và join conversation
//   Future<void> initHub({
//     required String conversationId,
//     required OnReceiveMessage onReceiveMessage,
//   }) async {
//     _onReceiveMessage = onReceiveMessage;
//
//     if (_hubConnection != null && _hubConnection!.state == HubConnectionState.connected) {
//       debugPrint('[SignalR] Hub đã kết nối, join conversation $conversationId');
//       await joinConversation(conversationId);
//       return;
//     }
//
//     try {
//       final hubUrl = '${ApiConstants.baseUrl}/chatHub';
//       _hubConnection = HubConnectionBuilder()
//           .withUrl(
//         hubUrl,
//         HttpConnectionOptions(
//           accessTokenFactory: () async {
//             final prefs = await SharedPreferences.getInstance();
//             return prefs.getString('token') ?? '';
//           },
//         ),
//       )
//           .withAutomaticReconnect()
//           .build();
//
//       // Listen message
//       _hubConnection!.off('ReceiveMessage');
//       _hubConnection!.on('ReceiveMessage', (args) {
//         if (args != null && args.isNotEmpty && _onReceiveMessage != null) {
//           final data = Map<String, dynamic>.from(args[0]);
//           debugPrint('[SignalR] Nhận message: $data');
//           _onReceiveMessage!(data);
//         }
//       });
//
//       // Connection closed
//       _hubConnection!.onclose((error) {
//         debugPrint('[SignalR] Hub đóng kết nối: $error');
//         _isConnected = false;
//         _startReconnect();
//       });
//
//       // Start hub
//       await _hubConnection!.start();
//       _isConnected = true;
//       debugPrint('[SignalR] Hub đã kết nối');
//
//       // Join conversation
//       if (conversationId.isNotEmpty) {
//         await joinConversation(conversationId);
//       }
//     } catch (e, stack) {
//       debugPrint('[SignalR] Lỗi init hub: $e\n$stack');
//     }
//   }
//
//   /// Tự động reconnect
//   void _startReconnect() {
//     if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
//
//     _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (_hubConnection == null) return;
//       if (_hubConnection!.state != HubConnectionState.connected) {
//         try {
//           debugPrint('[SignalR] Thử reconnect...');
//           await _hubConnection!.start();
//           _isConnected = true;
//           debugPrint('[SignalR] Reconnect thành công');
//           timer.cancel();
//         } catch (e) {
//           debugPrint('[SignalR] Reconnect thất bại: $e');
//         }
//       } else {
//         _isConnected = true;
//         timer.cancel();
//       }
//     });
//   }
//
//   /// Join conversation
//   Future<void> joinConversation(String conversationId) async {
//     if (_hubConnection != null && _hubConnection!.state == HubConnectionState.connected) {
//       try {
//         await _hubConnection!.invoke('JoinConversation', args: [conversationId]);
//         debugPrint('[SignalR] Đã join conversation $conversationId');
//       } catch (e) {
//         debugPrint('[SignalR] Lỗi join conversation $conversationId: $e');
//       }
//     } else {
//       debugPrint('[SignalR] Không thể join, hub chưa kết nối');
//     }
//   }
//
//   /// Gửi tin nhắn text
//   Future<void> sendTextMessage({
//     required String conversationId,
//     required String senderId,
//     required String content,
//   }) async {
//     if (_hubConnection != null &&
//         _hubConnection!.state == HubConnectionState.connected &&
//         content.trim().isNotEmpty) {
//       await _hubConnection!.invoke('SendTextMessage', args: [conversationId, senderId, content]);
//       debugPrint('[SignalR] Gửi text message: $content');
//     }
//   }
//
//   /// Gửi tin nhắn hình ảnh
//   Future<void> sendImageMessage({
//     required String conversationId,
//     required String senderId,
//     required List<String> imageUrls,
//   }) async {
//     if (_hubConnection == null ||
//         _hubConnection!.state != HubConnectionState.connected) {
//       debugPrint('[SignalR] Hub chưa kết nối, không thể gửi image');
//       return;
//     }
//
//     if (imageUrls.isEmpty) {
//       debugPrint('[SignalR] Danh sách ảnh rỗng, không gửi image');
//       return;
//     }
//
//     try {
//       debugPrint('[SignalR] Gửi image message:');
//       debugPrint('ConversationId: $conversationId');
//       debugPrint('SenderId: $senderId');
//       debugPrint('Image URLs: $imageUrls');
//
//       // Gửi mảng thẳng cho backend
//       await _hubConnection!.invoke(
//         'SendImageMessage',
//         args: [
//           conversationId,
//           senderId,
//           imageUrls, // List<String>
//         ],
//       );
//
//       debugPrint('[SignalR] Gửi image message thành công: ${imageUrls.length} ảnh');
//
//     } catch (e) {
//       debugPrint('[SignalR] Lỗi gửi image message: $e');
//     }
//   }
//
//   /// Stop hub
//   Future<void> stop() async {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//     _isConnected = false;
//     if (_hubConnection != null) {
//       await _hubConnection!.stop();
//       debugPrint('[SignalR] Hub stopped');
//     }
//   }
//
//   bool get isConnected => _isConnected;
// }
//

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../core/config/api_constants.dart';

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

      // Gửi mảng thẳng cho backend
      await _hubConnection!.invoke(
        'SendImageMessage',
        args: [
          conversationId,
          senderId,
          imageUrls, // List<String>
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
