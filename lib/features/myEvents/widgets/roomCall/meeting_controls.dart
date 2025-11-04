import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final bool isHost;
  final bool isCameraOn;
  final bool isMicOn;
  final bool hasStartedEvent;

  final VoidCallback onToggleCamera;
  final VoidCallback onToggleMic;
  final VoidCallback onChatToggle;
  final VoidCallback onParticipants;
  final VoidCallback onSettings;
  final VoidCallback onLeave;
  final VoidCallback? onStartEvent;
  final VoidCallback? onEndEvent;

  const MeetingControls({
    Key? key,
    required this.isHost,
    required this.isCameraOn,
    required this.isMicOn,
    required this.hasStartedEvent,
    required this.onToggleCamera,
    required this.onToggleMic,
    required this.onChatToggle,
    required this.onParticipants,
    required this.onSettings,
    required this.onLeave,
    this.onStartEvent,
    this.onEndEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              icon: isMicOn ? Icons.mic : Icons.mic_off,
              color: isMicOn ? Colors.white : Colors.redAccent,
              onPressed: onToggleMic,
              tooltip: isMicOn ? "Tắt mic" : "Bật mic",
            ),
            const SizedBox(width: 14),
            _buildButton(
              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
              color: isCameraOn ? Colors.white : Colors.redAccent,
              onPressed: onToggleCamera,
              tooltip: isCameraOn ? "Tắt camera" : "Bật camera",
            ),
            const SizedBox(width: 14),
            _buildButton(
              icon: Icons.chat,
              color: Colors.white,
              onPressed: onChatToggle,
              tooltip: "Chat",
            ),
            const SizedBox(width: 14),
            _buildButton(
              icon: Icons.people,
              color: Colors.white,
              onPressed: onParticipants,
              tooltip: "Người tham gia",
            ),
            const SizedBox(width: 14),

            if (isHost) ...[
              hasStartedEvent
                  ? _buildButton(
                icon: Icons.stop_circle,
                color: Colors.redAccent,
                onPressed: onEndEvent ?? () {},
                tooltip: "Kết thúc sự kiện",
              )
                  : _buildButton(
                icon: Icons.play_circle_fill,
                color: Colors.greenAccent,
                onPressed: onStartEvent ?? () {},
                tooltip: "Bắt đầu sự kiện",
              ),
              const SizedBox(width: 14),
            ],

            _buildButton(
              icon: Icons.call_end,
              color: Colors.redAccent,
              onPressed: onLeave,
              tooltip: "Rời phòng",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
