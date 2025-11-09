import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_constants.dart';
import '../../../routes/app_routes.dart';

typedef UserStatusChangedCallback = void Function(Map<String, dynamic> data);

class UserPresenceService {
  final UserStatusChangedCallback? onUserStatusChanged;
  final String hubUrl = "${ApiConstants.baseUrl}/UserPresenceHub";

  HubConnection? _connection;
  bool _isConnected = false;
  String? currentUserId;

  final StreamController<Map<String, dynamic>> _statusStreamController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get statusStream =>
      _statusStreamController.stream;

  UserPresenceService({
    this.onUserStatusChanged,
  });

  bool get isConnected => _isConnected;

  Future<void> initHub() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      debugPrint("❌ [UserPresenceHub] No authentication token found");
      return;
    }

    try {
      final payload = _parseJwt(token);
      currentUserId = payload['userId'] ?? payload['sub'] ?? payload['Id'];
      debugPrint("🔑 [UserPresenceHub] Current userId: $currentUserId");
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Failed to parse token: $e");
    }

    _connection = HubConnectionBuilder()
        .withUrl(hubUrl, HttpConnectionOptions(
      accessTokenFactory: () async => token,
    ))
        .withAutomaticReconnect()
        .build();

    _connection!.onclose((error) {
      debugPrint("🔴 [UserPresenceHub] Connection closed: $error");
      _isConnected = false;
    });

    _connection!.onreconnecting((error) {
      debugPrint("🔄 [UserPresenceHub] Reconnecting... $error");
      _isConnected = false;
    });

    _connection!.onreconnected((connectionId) async {
      debugPrint("✅ [UserPresenceHub] Reconnected: $connectionId");
      _isConnected = true;
      if (currentUserId != null) {
        await updateOnlineStatus(currentUserId!);
      }
    });

    // Listen sự kiện từ server
    _connection!.on("UserStatusChanged", (args) {
      if (args != null && args.isNotEmpty) {
        final data = Map<String, dynamic>.from(args[0] as Map);
        debugPrint("👤 [UserPresenceHub] UserStatusChanged: $data");
        _statusStreamController.add(data);
        if (onUserStatusChanged != null) onUserStatusChanged!(data);
      }
    });

    try {
      await _connection!.start();
      debugPrint("✅ [UserPresenceHub] Connected successfully");
      _isConnected = true;
      if (currentUserId != null) {
        await updateOnlineStatus(currentUserId!);
      }
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Error connecting: $e");
    }
  }

  /// Cập nhật online/offline status cho 1 user
  Future<void> updateOnlineStatus(String userId) async {
    if (_connection == null || !_isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }
    try {
      await _connection!.invoke("UpdateUserOnlineStatus", args: [userId]);
      debugPrint("✅ Online status updated for user: $userId");
    } catch (e) {
      debugPrint("❌ Error updating online status: $e");
      rethrow;
    }
  }

  /// Lấy online status cho nhiều user
  Future<Map<String, bool>> getOnlineStatus(List<String> userIds) async {
    if (_connection == null || !_isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }
    try {
      final result = await _connection!.invoke("GetOnlineStatus", args: [userIds]);
      debugPrint("✅ Retrieved online status: $result");

      // Parse dynamic -> Map<String, bool>
      if (result is Map) {
        return result.map((key, value) => MapEntry(key.toString(), value as bool));
      }
      return {};
    } catch (e) {
      debugPrint("❌ Error getting online status: $e");
      rethrow;
    }
  }


  /// Dừng kết nối
  Future<void> stop() async {
    if (_connection != null) {
      await _connection!.stop();
      debugPrint("🔌 [UserPresenceHub] Connection stopped");
    }
    _isConnected = false;
  }

  /// Hàm parse payload JWT
  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return Map<String, dynamic>.from(jsonDecode(decoded));
  }
}

class UserPresenceManager {
  static final UserPresenceManager _instance = UserPresenceManager._internal();
  factory UserPresenceManager() => _instance;
  UserPresenceManager._internal();

  late UserPresenceService service;

  Future<void> init() async {
    service = UserPresenceService();
    await service.initHub();
  }
}

class HubManager extends StatefulWidget {
  final Widget child;
  const HubManager({required this.child, super.key});

  @override
  State<HubManager> createState() => _HubManagerState();
}

class _HubManagerState extends State<HubManager> with WidgetsBindingObserver {
  bool _hubStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndStartHub();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndStartHub();
    }
  }

  Future<void> _checkAndStartHub() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && !_hubStarted) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != AppRoutes.login) {
        await UserPresenceManager().init();
        _hubStarted = true;
        debugPrint("✅ UserPresenceManager initialized in HubManager");
      }
    }
  }

  Future<void> _stopHubIfNeeded() async {
    if (_hubStarted) {
      await UserPresenceManager().service.stop();
      _hubStarted = false;
      debugPrint("🔌 UserPresenceManager stopped in HubManager");
    }
  }

  @override
  void dispose() {
    _stopHubIfNeeded();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

