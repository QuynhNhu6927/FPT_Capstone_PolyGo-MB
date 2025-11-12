import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool isMicOn = true;
  bool isCameraOn = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      isMicOn = !isMicOn;
    });
  }

  void _toggleCamera() {
    setState(() {
      isCameraOn = !isCameraOn;
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video
            Positioned.fill(
              child: VideoView(renderer: _remoteRenderer),
            ),

            // Local video (small overlay)
            Positioned(
              top: 16,
              right: 16,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey.shade800,
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

            // Top bar: remote user name
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'hehe',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: CallControls(
                isMicOn: isMicOn,
                isCameraOn: isCameraOn,
                onToggleMic: _toggleMic,
                onToggleCamera: _toggleCamera,
                onEndCall: _endCall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Video View wrapper ---
class VideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const VideoView({super.key, required this.renderer});

  @override
  Widget build(BuildContext context) {
    return renderer.textureId != null
        ? RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    )
        : Container(color: Colors.black);
  }
}

/// --- Call Controls ---
class CallControls extends StatelessWidget {
  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onEndCall;

  const CallControls({
    super.key,
    required this.isMicOn,
    required this.isCameraOn,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: isMicOn ? Icons.mic : Icons.mic_off,
          color: isMicOn ? Colors.white : Colors.redAccent,
          onPressed: onToggleMic,
        ),
        const SizedBox(width: 24),
        _buildButton(
          icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
          color: isCameraOn ? Colors.white : Colors.redAccent,
          onPressed: onToggleCamera,
        ),
        const SizedBox(width: 24),
        _buildButton(
          icon: Icons.call_end,
          color: Colors.redAccent,
          onPressed: onEndCall,
        ),
      ],
    );
  }

  Widget _buildButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
