import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final bool isHost;
  final bool isCameraOn;
  final bool isMicOn;
  final bool hasStartedEvent;
  final bool isHandRaised;
  final VoidCallback onToggleHand;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleMic;
  final VoidCallback onChatToggle;
  final VoidCallback onParticipants;
  final VoidCallback onSettings;
  final VoidCallback onLeave;
  final VoidCallback? onStartEvent;
  final VoidCallback? onEndEvent;
  final VoidCallback onTranscribeToggle;
  final VoidCallback onCaptionsToggle;
  final bool isTranscriptionEnabled;
  final bool isCaptionsEnabled;
  final VoidCallback? onCaptionsLongPress;

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
    required this.isHandRaised,
    required this.onToggleHand,
    required this.onTranscribeToggle,
    required this.onCaptionsToggle,
    required this.isTranscriptionEnabled,
    required this.isCaptionsEnabled,
    required this.onCaptionsLongPress,
    this.onStartEvent,
    this.onEndEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;

    // Hàng trên cho màn hình nhỏ
    final topRow = [
      _buildButton(
        icon: isMicOn ? Icons.mic : Icons.mic_off,
        color: isMicOn ? Colors.white : Colors.redAccent,
        onPressed: onToggleMic,
      ),
      const SizedBox(width: 14),
      _buildButton(
        icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
        color: isCameraOn ? Colors.white : Colors.redAccent,
        onPressed: onToggleCamera,
      ),
      const SizedBox(width: 14),
      _buildButton(
        icon: isTranscriptionEnabled ? Icons.record_voice_over : Icons.voice_over_off,
        color: isTranscriptionEnabled ? Colors.white : Colors.redAccent,
        onPressed: onTranscribeToggle,
      ),
      const SizedBox(width: 14),
      _buildButton(
        icon: isCaptionsEnabled ? Icons.closed_caption : Icons.closed_caption_disabled_rounded,
        color: isCaptionsEnabled ? Colors.white : Colors.redAccent,
        onPressed: onCaptionsToggle,
        onLongPress: isCaptionsEnabled ? onCaptionsLongPress : null,
      ),

    ];

    // Hàng dưới hoặc row chính cho màn hình rộng
    final bottomRow = [
      _buildButton(
        icon: Icons.chat,
        color: Colors.white,
        onPressed: onChatToggle,
      ),
      const SizedBox(width: 14),
      if (!isHost) ...[
        _buildButton(
          icon: isHandRaised ? Icons.back_hand : Icons.pan_tool_alt_outlined,
          color: isHandRaised ? Colors.amber : Colors.white,
          onPressed: onToggleHand,
        ),
        const SizedBox(width: 14),
      ],
      _buildButton(
        icon: Icons.people,
        color: Colors.white,
        onPressed: onParticipants,
      ),
      const SizedBox(width: 14),
      if (isHost) ...[
        hasStartedEvent
            ? _buildButton(
          icon: Icons.stop_circle,
          color: Colors.redAccent,
          onPressed: onEndEvent ?? () {},
        )
            : _buildButton(
          icon: Icons.play_circle_fill,
          color: Colors.greenAccent,
          onPressed: onStartEvent ?? () {},
        ),
        const SizedBox(width: 14),
      ],
      _buildButton(
        icon: Icons.call_end,
        color: Colors.redAccent,
        onPressed: onLeave,
      ),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: isSmallScreen
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: topRow,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bottomRow,
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...topRow, const SizedBox(width: 14), ...bottomRow],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
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
