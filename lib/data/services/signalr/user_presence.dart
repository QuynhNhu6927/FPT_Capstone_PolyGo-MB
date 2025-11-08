import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../core/config/api_constants.dart';

class UserPresenceService {
  static final UserPresenceService _instance = UserPresenceService._internal();
  factory UserPresenceService() => _instance;
  UserPresenceService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  Future<void> initHub() async {
    final hubUrl = '${ApiConstants.baseUrl}/userPresenceHub';
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      HttpConnectionOptions(
        accessTokenFactory: () async {
          final prefs = await SharedPreferences.getInstance();
          return prefs.getString('token') ?? '';
        },
      ),
    ).withAutomaticReconnect().build();

    _hubConnection!.on('UserStatusChanged', (args) {
      debugPrint('[PresenceHub] Received args: $args');
      if (args != null && args.isNotEmpty) {
        final data = Map<String, dynamic>.from(args[0]);
        debugPrint('[PresenceHub] Parsed data: $data');
        _statusController.add(data);
      }
    });

    _hubConnection!.onclose((error) {
      _isConnected = false;
      _startReconnect();
    });

    await _hubConnection!.start();
    _isConnected = true;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isNotEmpty) {
      await _hubConnection!.invoke('UpdateUserOnlineStatus', args: [userId]);
    }
  }

  void _startReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_hubConnection == null) return;
      if (_hubConnection!.state != HubConnectionState.connected) {
        try {
          await _hubConnection!.start();
          _isConnected = true;
          timer.cancel();
        } catch (_) {}
      } else {
        _isConnected = true;
        timer.cancel();
      }
    });
  }

  Future<void> stop() async {
    _reconnectTimer?.cancel();
    await _hubConnection?.stop();
  }
}
