import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import 'event_room_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String hostId;
  final String eventStatus;
  final String hostName;
  final DateTime startAt;

  const WaitingRoomScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventStatus,
    required this.hostId,
    required this.hostName,
    required this.startAt,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  String? _currentUserId;
  bool _isHost = false;
  bool _eventStarted = false;
  bool isCameraOn = true;
  bool isMicOn = true;
  bool isInitialized = false;
  String? permissionError;

  final _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkEventStatus();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final user = await AuthRepository(AuthService(ApiClient())).me(token);
      if (!mounted) return;
      setState(() {
        _currentUserId = user.id;
        _isHost = user.id == widget.hostId;
      });
      _initStream();
    } catch (_) {}
  }

  void _checkEventStatus() {
    final now = DateTime.now();
    setState(() {
      _eventStarted = now.isAfter(widget.startAt);
    });
  }

  @override
  void dispose() {
    _localRenderer.srcObject?.getTracks().forEach((t) => t.stop());
    _localRenderer.dispose();
    super.dispose();
  }

  Future<void> _initStream() async {
    try {
      await _localRenderer.initialize();
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      _localRenderer.srcObject = stream;
      setState(() => isInitialized = true);
    } catch (_) {
      setState(() {
        permissionError =
        "Permission denied. Please allow access to microphone and camera.";
      });
    }
  }

  void _toggleAudio() {
    final stream = _localRenderer.srcObject;
    if (stream != null) {
      final track = stream.getAudioTracks().isNotEmpty ? stream.getAudioTracks().first : null;
      if (track != null) {
        track.enabled = !track.enabled;
        setState(() => isMicOn = track.enabled);
      }
    }
  }

  void _toggleVideo() {
    final stream = _localRenderer.srcObject;
    if (stream != null) {
      final track = stream.getVideoTracks().isNotEmpty ? stream.getVideoTracks().first : null;
      if (track != null) {
        track.enabled = !track.enabled;
        setState(() => isCameraOn = track.enabled);
      }
    }
  }

  Future<void> _handleJoin() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingRoomScreen(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
          isHost: _isHost,
          hostId: widget.hostId,
          eventStatus: widget.eventStatus,
          initialMicOn: isMicOn,
          initialCameraOn: isCameraOn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0D0D0D),
        Color(0xFF1A1A1A),
        Color(0xFF000000),
      ],
    )
        : const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF6F8FB),
        Color(0xFFEFF2F5),
        Color(0xFFFFFFFF),
      ],
    );

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;

    if (!isInitialized) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : Colors.blueAccent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Text(
                  widget.eventTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Host: ${widget.hostName}",
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isCameraOn && _localRenderer.srcObject != null
                            ? RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover,
                        )
                            : Center(
                          child: Icon(
                            Icons.videocam_off,
                            color: isDark ? Colors.grey : Colors.black38,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (permissionError != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      permissionError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: isMicOn ? Icons.mic : Icons.mic_off,
                        active: isMicOn,
                        onTap: _toggleAudio,
                        isDark: isDark,
                      ),
                      _buildControlButton(
                        icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                        active: isCameraOn,
                        onTap: _toggleVideo,
                        isDark: isDark,
                      ),
                      _buildJoinButton(isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor:
        active ? (isDark ? Colors.white24 : Colors.black12) : Colors.white10,
        child: Icon(
          icon,
          color: active ? (isDark ? Colors.white : Colors.black87) : Colors.redAccent,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildJoinButton(bool isDark) {
    final canJoin = permissionError == null && (_isHost || _eventStarted);
    return ElevatedButton(
      onPressed: canJoin ? _handleJoin : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHost
            ? Colors.green
            : (isDark ? Colors.blueAccent : Colors.blue),
        disabledBackgroundColor:
        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        _isHost ? (_eventStarted ? "Bắt đầu" : "Chờ bắt đầu") : "Tham gia",
        style: TextStyle(
          fontSize: 16,
          color: canJoin ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
        ),
      ),
    );
  }
}
