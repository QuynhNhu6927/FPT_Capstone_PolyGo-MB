import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/webrtc_controller.dart';
import 'event_room_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String hostId;
  final String eventStatus;
  final String hostName;
  final DateTime eventStartAt;

  const WaitingRoomScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventStatus,
    required this.hostId,
    required this.hostName,
    required this.eventStartAt,
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
  bool showSettings = false;
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
    } catch (e) {
      //
    }
  }

  void _checkEventStatus() {
    final now = DateTime.now();
    setState(() {
      _eventStarted = now.isAfter(widget.eventStartAt);
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

      WebRTCController controller = WebRTCController(
        eventId: widget.eventId,
        userName: 'Preview',
        isHost: _isHost,
      );
      controller.localStream = stream;

      setState(() => isInitialized = true);
    } catch (e) {
      setState(() {
        permissionError =
        "Permission denied. Please allow access to microphone and camera.";
      });
    }
  }

  void _toggleAudio() {
    final stream = _localRenderer.srcObject;
    if (stream != null) {
      final track = stream.getAudioTracks().firstOrNull;
      if (track != null) {
        track.enabled = !track.enabled;
        setState(() => isMicOn = track.enabled);
      }
    }
  }

  void _toggleVideo() {
    final stream = _localRenderer.srcObject;
    if (stream != null) {
      final track = stream.getVideoTracks().firstOrNull;
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
          eventStatus: widget.eventStatus,
          initialMicOn: isMicOn,
          initialCameraOn: isCameraOn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.eventTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black54,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: isCameraOn && _localRenderer.srcObject != null
                      ? RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit:
                    RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                      : const Center(
                    child: Icon(Icons.videocam_off,
                        color: Colors.grey, size: 64),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mic / Cam / Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: isMicOn ? Icons.mic : Icons.mic_off,
                  active: isMicOn,
                  onTap: _toggleAudio,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                  active: isCameraOn,
                  onTap: _toggleVideo,
                ),
              ],
            ),

            if (permissionError != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  permissionError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 30),

            // Start / Join button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: permissionError != null
                    ? null
                    : (_isHost || _eventStarted)
                    ? _handleJoin
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor:
                  _isHost ? Colors.green : Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(
                  _isHost ? Icons.play_arrow : Icons.login,
                  color: Colors.white,
                ),
                label: Text(
                  _isHost
                      ? (_eventStarted ? "Join Meeting" : "Wait for Start")
                      : "Join Meeting",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: active ? Colors.white24 : Colors.white10,
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.redAccent,
          size: 28,
        ),
      ),
    );
  }
}
