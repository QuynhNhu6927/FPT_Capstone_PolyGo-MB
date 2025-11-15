import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_constants.dart';
import '../../../features/chat/screens/calling_screen.dart';
import '../../../features/chat/screens/incoming_call.dart';
import '../../../main.dart';

typedef OnUserStatusChanged = void Function(Map<String, dynamic> data);

class UserPresenceService {
  final OnUserStatusChanged? onUserStatusChanged;

  final String hubUrl = "${ApiConstants.baseUrl}/communicationHub";

  HubConnection? connection;
  bool isConnected = false;
  String? error;
  String? currentUserId;

  final StreamController<Map<String, dynamic>> _statusStreamController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get statusStream =>
      _statusStreamController.stream;

  UserPresenceService({this.onUserStatusChanged});

  Future<void> initHub() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      error = "No authentication token found";
      return;
    }

    try {
      final payload = _parseJwt(token);
      currentUserId = payload['userId'] ?? payload['sub'] ?? payload['Id'];
    } catch (e) {
      //
    }

    // Khởi tạo connection
    final hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      HttpConnectionOptions(accessTokenFactory: () async => token),
    )
        .build();

    connection = hubConnection;

    hubConnection.onreconnecting((error) {
      isConnected = false;
    });

    hubConnection.onreconnected((connectionId) async {
      isConnected = true;
      error = null;

      if (currentUserId != null) {
        try {
          await updateOnlineStatus(currentUserId!);
        } catch (e) {
          //
        }
      }
    });

    hubConnection.onclose((error) {
      isConnected = false;
      if (error != null && !error.toString().contains("negotiation")) {
        this.error = error.toString();
      }
    });

    hubConnection.on("UserStatusChanged", (args) {
      if (args != null && args.isNotEmpty) {
        final data = Map<String, dynamic>.from(args[0] as Map);
        _statusStreamController.add(data);
        onUserStatusChanged?.call(data);
      }
    });

    try {
      await hubConnection.start();
      isConnected = true;
      error = null;

      if (currentUserId != null) {
        await updateOnlineStatus(currentUserId!);
      } else {
        //
      }
    } catch (e) {
      if (!e.toString().contains("negotiation")) {
        error = e.toString();
      }
    }
  }

  Future<void> updateOnlineStatus(String userId) async {
    if (connection == null || !isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }

    try {
      await connection!.invoke("UpdateUserOnlineStatus", args: [userId]);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, bool>> getOnlineStatus(List<String> userIds) async {
    if (connection == null || !isConnected) {
      throw Exception("Not connected to UserPresenceHub");
    }

    try {
      final result =
      await connection!.invoke("GetOnlineStatus", args: [userIds]);

      if (result != null) {
        return result.map<String, bool>((key, value) {
          final boolVal = (value is bool) ? value : (value.toString().toLowerCase() == 'true');
          return MapEntry(key.toString(), boolVal);
        });
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stop() async {
    if (connection != null) {
      try {

        connection!.onreconnecting((_) {});
        connection!.onreconnected((_) {});

        if (connection!.state != HubConnectionState.disconnected) {
          await connection!.stop();
          // optional: đợi thêm chút thời gian để server kịp nhận disconnect
          await Future.delayed(const Duration(milliseconds: 500));
        }

      } catch (e) {
        //
      } finally {
        isConnected = false;
      }
    }
  }

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

  Future<void> init({OnUserStatusChanged? onUserStatusChanged}) async {
    service = UserPresenceService(onUserStatusChanged: onUserStatusChanged);
    await service.initHub();
  }

  Future<void> stop() async {
    await service.stop();
  }
}

class HubManager extends StatefulWidget {
  final Widget child;
  const HubManager({required this.child,super.key});

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

    if (_hubStarted) {
      await UserPresenceManager().service.connection?.stop();
      UserPresenceManager().service.isConnected = false;
      _hubStarted = false;
      await Future.delayed(Duration(milliseconds: 300));
    }

    if (token != null && !_hubStarted) {
      await UserPresenceManager().init();
      _hubStarted = true;
      _registerIncomingCallHandler();
    }
  }

  void _registerIncomingCallHandler() {
    UserPresenceManager().service.registerCallHandlers(
      onIncomingCall: ({
        required String callerId,
        required bool isVideoCall,
        String? callerName,
        String? callerAvatar,
      }) {
        debugPrint('📞 Incoming call from $callerName ($callerId)');

        // Đảm bảo chạy trên main thread
        scheduleMicrotask(() {
          if (!mounted) return;
          globalNavigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(
                callerId: callerId,
                callerName: callerName ?? 'Unknown',
                callerAvatar: callerAvatar ?? '',
                isVideoCall: isVideoCall,
                onAccept: () async {
                  if (!mounted) return;
                  globalNavigatorKey.currentState?.pop();
                  await UserPresenceManager().service.respondCall(callerId, true);
                  if (!mounted) return;
                  globalNavigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (_) => CallingScreen(
                        receiverId: callerId,
                        receiverName: callerName ?? 'Unknown',
                        receiverAvatar: callerAvatar ?? '',
                        isVideoCall: isVideoCall,
                        isCaller: false,
                        initialIsConnecting: false,
                      ),
                    ),
                  );
                },
                onDecline: () async {
                  if (!mounted) return;
                  globalNavigatorKey.currentState?.pop();
                  await UserPresenceManager().service.respondCall(callerId, false);
                },
              ),
            ),
          );
        });
      },
    );
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

typedef OnIncomingCall = void Function({
required String callerId,
required bool isVideoCall,
String? callerName,
String? callerAvatar,
});

typedef OnCallAccepted = void Function(String receiverId);
typedef OnCallDeclined = void Function(String receiverId);
typedef OnCallEnded = void Function();
typedef OnUpdateMediaState = void Function(String userId, bool micOn, bool camOn);
typedef OnReceiveOffer = void Function(String sdp);
typedef OnReceiveAnswer = void Function(String sdp);
typedef OnReceiveIceCandidate = void Function(String candidate);

extension UserPresenceCallExtension on UserPresenceService {

  Future<void> startCall(String receiverId, bool isVideoCall) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("StartCall", args: [receiverId, isVideoCall]);
    } catch (e) {
      debugPrint("❌ Error starting call: $e");
    }
  }

  Future<void> respondCall(String callerId, bool accepted) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("RespondCall", args: [callerId, accepted]);
    } catch (e) {
      debugPrint("❌ Error responding call: $e");
    }
  }

  Future<void> toggleMedia(bool micOn, bool camOn) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("ToggleMedia", args: [micOn, camOn]);
    } catch (e) {
      debugPrint("❌ Error toggling media: $e");
    }
  }

  Future<void> endCall() async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("EndCall");
    } catch (e) {
      debugPrint("❌ Error ending call: $e");
    }
  }

  Future<void> sendOffer(String receiverId, String sdp) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("SendOffer", args: [receiverId, sdp]);
    } catch (e) {
      debugPrint("❌ Error sending offer: $e");
    }
  }

  Future<void> sendAnswer(String receiverId, String sdp) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("SendAnswer", args: [receiverId, sdp]);
    } catch (e) {
      debugPrint("❌ Error sending answer: $e");
    }
  }

  Future<void> sendIceCandidate(String receiverId, String candidate) async {
    if (!isConnected || connection == null) return;
    try {
      await connection!.invoke("SendIceCandidate", args: [receiverId, candidate]);
    } catch (e) {
      debugPrint("❌ Error sending ICE candidate: $e");
    }
  }

  void registerCallHandlers({
    OnIncomingCall? onIncomingCall,
    OnCallAccepted? onCallAccepted,
    OnCallDeclined? onCallDeclined,
    OnCallEnded? onCallEnded,
    OnUpdateMediaState? onUpdateMediaState,
    OnReceiveOffer? onReceiveOffer,
    OnReceiveAnswer? onReceiveAnswer,
    OnReceiveIceCandidate? onReceiveIceCandidate,
  }) {
    if (connection == null) {
      debugPrint("❌ registerCallHandlers: connection is null");
      return;
    }

    // Incoming call
    connection!.on("IncomingCall", (args) {
      debugPrint("📞 IncomingCall event received: $args"); // <- log thêm
      if (args != null && args.length >= 4) {
        final callerId = args[0] as String;
        final isVideoCall = args[1] as bool;
        final callerName = args[2] as String?;
        final callerAvatar = args[3] as String?;
        debugPrint("📞 CallerId: $callerId, isVideoCall: $isVideoCall, callerName: $callerName, callerAvatar: $callerAvatar");
        onIncomingCall?.call(
          callerId: callerId,
          isVideoCall: isVideoCall,
          callerName: callerName,
          callerAvatar: callerAvatar,
        );
      } else {
        debugPrint("⚠️ IncomingCall event has invalid args: $args");
      }
    });

    // Call accepted
    connection!.on("CallAccepted", (args) {
      debugPrint("✅ CallAccepted event: $args");
      if (args != null && args.isNotEmpty) {
        onCallAccepted?.call(args[0] as String);
      }
    });

    // Call declined
    connection!.on("CallDeclined", (args) {
      debugPrint("❌ CallDeclined event: $args");
      if (args != null && args.isNotEmpty) {
        onCallDeclined?.call(args[0] as String);
      }
    });

    // Call ended
    connection!.on("CallEnded", (args) {
      debugPrint("📴 CallEnded event: $args");
      onCallEnded?.call();
    });

    // Update media state
    connection!.on("UpdateMediaState", (args) {
      debugPrint("🎤 UpdateMediaState event: $args");
      if (args != null && args.length >= 3) {
        onUpdateMediaState?.call(args[0] as String, args[1] as bool, args[2] as bool);
      }
    });

    // Receive SDP Offer
    connection!.on("ReceiveOffer", (args) {
      debugPrint("📨 ReceiveOffer event: $args");
      if (args != null && args.isNotEmpty) {
        onReceiveOffer?.call(args[0] as String);
      }
    });

    // Receive SDP Answer
    connection!.on("ReceiveAnswer", (args) {
      debugPrint("📩 ReceiveAnswer event: $args");
      if (args != null && args.isNotEmpty) {
        onReceiveAnswer?.call(args[0] as String);
      }
    });

    // Receive ICE Candidate
    connection!.on("ReceiveIceCandidate", (args) {
      debugPrint("🧊 ReceiveIceCandidate event: $args");
      if (args != null && args.isNotEmpty) {
        onReceiveIceCandidate?.call(args[0] as String);
      }
    });
  }
}