import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_constants.dart';
import '../../../routes/app_routes.dart';

typedef OnUserStatusChanged = void Function(Map<String, dynamic> data);

class UserPresenceService {
  // === Callbacks ===
  final OnUserStatusChanged? onUserStatusChanged;

  // === Hub URL giống React
  final String hubUrl = "${ApiConstants.baseUrl}/communicationHub";

  // === Trạng thái kết nối ===
  HubConnection? connection;
  bool isConnected = false;
  String? error;
  String? currentUserId;

  // === Luồng stream để truyền sự kiện ra ngoài (tùy chọn) ===
  final StreamController<Map<String, dynamic>> _statusStreamController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get statusStream =>
      _statusStreamController.stream;

  UserPresenceService({this.onUserStatusChanged});

  // ============================================================
  //                      INIT CONNECTION
  // ============================================================
  Future<void> initHub() async {
    debugPrint("🚀 [UserPresenceHub] Initializing connection...");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      debugPrint("❌ [UserPresenceHub] No authentication token found");
      error = "No authentication token found";
      return;
    }

    // Parse token để lấy userId
    try {
      final payload = _parseJwt(token);
      currentUserId = payload['userId'] ?? payload['sub'] ?? payload['Id'];
      debugPrint("🔑 [UserPresenceHub] Token payload: $payload");
      debugPrint("👤 [UserPresenceHub] Current user ID: $currentUserId");
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Failed to parse token: $e");
    }

    // Khởi tạo connection
    final hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      HttpConnectionOptions(accessTokenFactory: () async => token),
    )
        .build();

    connection = hubConnection;

    debugPrint("🔗 [UserPresenceHub] Hub URL: $hubUrl");

    // ============================================================
    //                        HANDLERS
    // ============================================================

    // Khi reconnecting
    hubConnection.onreconnecting((error) {
      debugPrint("🔄 [UserPresenceHub] Reconnecting... $error");
      isConnected = false;
    });

    // Khi reconnected
    hubConnection.onreconnected((connectionId) async {
      debugPrint("✅ [UserPresenceHub] Reconnected: $connectionId");
      isConnected = true;
      error = null;

      if (currentUserId != null) {
        try {
          await updateOnlineStatus(currentUserId!);
        } catch (e) {
          debugPrint("❌ Error updating online status after reconnect: $e");
        }
      }
    });

    // Khi close
    hubConnection.onclose((error) {
      debugPrint("🔴 [UserPresenceHub] Connection closed: $error");
      isConnected = false;
      if (error != null && !error.toString().contains("negotiation")) {
        this.error = error.toString();
      }
    });

    // Khi nhận sự kiện từ server
    hubConnection.on("UserStatusChanged", (args) {
      if (args != null && args.isNotEmpty) {
        final data = Map<String, dynamic>.from(args[0] as Map);
        debugPrint("👤 [UserPresenceHub] UserStatusChanged: $data");
        _statusStreamController.add(data);
        onUserStatusChanged?.call(data);
      }
    });

    // ============================================================
    //                        START CONNECTION
    // ============================================================
    try {
      await hubConnection.start();
      debugPrint("✅ [UserPresenceHub] Connected successfully");
      isConnected = true;
      error = null;

      // Gửi trạng thái online ngay sau khi kết nối
      if (currentUserId != null) {
        await updateOnlineStatus(currentUserId!);
      } else {
        debugPrint("⚠️ [UserPresenceHub] No current user ID found");
      }
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Error connecting: $e");
      if (!e.toString().contains("negotiation")) {
        error = e.toString();
      }
    }
  }

  // ============================================================
  //                   UPDATE ONLINE STATUS
  // ============================================================
  Future<void> updateOnlineStatus(String userId) async {
    if (connection == null || !isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }

    try {
      await connection!.invoke("UpdateUserOnlineStatus", args: [userId]);
      debugPrint("✅ [UserPresenceHub] Online status updated for user: $userId");
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Error updating online status: $e");
      rethrow;
    }
  }

  // ============================================================
  //                   GET MULTIPLE USER STATUS
  // ============================================================
  Future<Map<String, bool>> getOnlineStatus(List<String> userIds) async {
    if (connection == null || !isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }

    try {
      final result =
      await connection!.invoke("GetOnlineStatus", args: [userIds]);

      debugPrint("✅ [UserPresenceHub] Retrieved online status: $result");

      if (result != null) {
        return result.map<String, bool>((key, value) {
          final boolVal = (value is bool) ? value : (value.toString().toLowerCase() == 'true');
          return MapEntry(key.toString(), boolVal);
        });
      }
      return {};
    } catch (e) {
      debugPrint("❌ [UserPresenceHub] Error getting online status: $e");
      rethrow;
    }
  }

  // ============================================================
  //                      STOP CONNECTION
  // ============================================================
  Future<void> stop() async {
    if (connection != null) {
      try {
        debugPrint("⏹ [UserPresenceHub] Stopping connection...");

        // 1️⃣ Tạm dừng handler reconnect để không reconnect lại
        connection!.onreconnecting((_) {});
        connection!.onreconnected((_) {});

        // 2️⃣ Nếu hub đang kết nối, stop và đợi cho đến khi state thành disconnected
        if (connection!.state != HubConnectionState.disconnected) {
          await connection!.stop();
          // optional: đợi thêm chút thời gian để server kịp nhận disconnect
          await Future.delayed(const Duration(milliseconds: 500));
        }

        debugPrint("🔌 [UserPresenceHub] Connection stopped successfully");
      } catch (e) {
        debugPrint("❌ [UserPresenceHub] Error stopping connection: $e");
      } finally {
        isConnected = false;
      }
    }
  }
  // ============================================================
  //                       JWT PARSER
  // ============================================================
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

// ============================================================
//                   SINGLETON MANAGER (GIỐNG HOOK)
// ============================================================

class UserPresenceManager {
  static final UserPresenceManager _instance = UserPresenceManager._internal();
  factory UserPresenceManager() => _instance;
  UserPresenceManager._internal();

  late UserPresenceService service;

  Future<void> init({OnUserStatusChanged? onUserStatusChanged}) async {
    service = UserPresenceService(onUserStatusChanged: onUserStatusChanged);
    await service.initHub();
  }

  Future<void> stop() async {
    await service.stop();
  }
}

// ============================================================
//                 HUB MANAGER WIDGET (GIỐNG PROVIDER)
// ============================================================

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
    if (state == AppLifecycleState.paused) {
      if (UserPresenceManager().service.isConnected) {
        UserPresenceManager().service.connection?.stop();
        UserPresenceManager().service.isConnected = false;
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
      await UserPresenceManager().service.connection?.stop();
      UserPresenceManager().service.isConnected = false;
      _hubStarted = false;
      await Future.delayed(Duration(milliseconds: 300));
    }

    if (token != null && !_hubStarted) {
      await UserPresenceManager().init();
      _hubStarted = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (UserPresenceManager().service.isConnected) {
      UserPresenceManager().service.connection?.stop();
      UserPresenceManager().service.isConnected = false;
    }

    super.dispose();
  }
  @override
  Widget build(BuildContext context) => widget.child;
}