// import 'package:flutter/material.dart';
//
// class MeetingControls extends StatelessWidget {
//   final bool isHost;
//   final bool isCameraOn;
//   final bool isMicOn;
//   final bool hasStartedEvent;
//   final bool isHandRaised;
//   final VoidCallback onToggleHand;
//   final VoidCallback onToggleCamera;
//   final VoidCallback onToggleMic;
//   final VoidCallback onChatToggle;
//   final VoidCallback onParticipants;
//   final VoidCallback onSettings;
//   final VoidCallback onLeave;
//   final VoidCallback? onStartEvent;
//   final VoidCallback? onEndEvent;
//   final VoidCallback onTranscribeToggle;
//   final VoidCallback onCaptionsToggle;
//   final bool isTranscriptionEnabled;
//   final bool isCaptionsEnabled;
//
//   const MeetingControls({
//     Key? key,
//     required this.isHost,
//     required this.isCameraOn,
//     required this.isMicOn,
//     required this.hasStartedEvent,
//     required this.onToggleCamera,
//     required this.onToggleMic,
//     required this.onChatToggle,
//     required this.onParticipants,
//     required this.onSettings,
//     required this.onLeave,
//     required this.isHandRaised,
//     required this.onToggleHand,
//     required this.onTranscribeToggle,
//     required this.onCaptionsToggle,
//     required this.isTranscriptionEnabled,
//     required this.isCaptionsEnabled,
//     this.onStartEvent,
//     this.onEndEvent,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 500;
//
//     // Hàng trên cho màn hình nhỏ
//     final topRow = [
//       _buildButton(
//         icon: isMicOn ? Icons.mic : Icons.mic_off,
//         color: isMicOn ? Colors.white : Colors.redAccent,
//         onPressed: onToggleMic,
//       ),
//       const SizedBox(width: 14),
//       _buildButton(
//         icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
//         color: isCameraOn ? Colors.white : Colors.redAccent,
//         onPressed: onToggleCamera,
//       ),
//       const SizedBox(width: 14),
//       _buildButton(
//         icon: isTranscriptionEnabled ? Icons.record_voice_over : Icons.voice_over_off,
//         color: isTranscriptionEnabled ? Colors.white : Colors.redAccent,
//         onPressed: onTranscribeToggle,
//       ),
//       const SizedBox(width: 14),
//       _buildButton(
//         icon: isCaptionsEnabled ? Icons.closed_caption : Icons.closed_caption_disabled_rounded,
//         color: isCaptionsEnabled ? Colors.white : Colors.redAccent,
//         onPressed: onCaptionsToggle,
//       ),
//
//     ];
//
//     // Hàng dưới hoặc row chính cho màn hình rộng
//     final bottomRow = [
//       _buildButton(
//         icon: Icons.chat,
//         color: Colors.white,
//         onPressed: onChatToggle,
//       ),
//       const SizedBox(width: 14),
//       if (!isHost) ...[
//         _buildButton(
//           icon: isHandRaised ? Icons.back_hand : Icons.pan_tool_alt_outlined,
//           color: isHandRaised ? Colors.amber : Colors.white,
//           onPressed: onToggleHand,
//         ),
//         const SizedBox(width: 14),
//       ],
//       _buildButton(
//         icon: Icons.people,
//         color: Colors.white,
//         onPressed: onParticipants,
//       ),
//       const SizedBox(width: 14),
//       if (isHost) ...[
//         hasStartedEvent
//             ? _buildButton(
//           icon: Icons.stop_circle,
//           color: Colors.redAccent,
//           onPressed: onEndEvent ?? () {},
//         )
//             : _buildButton(
//           icon: Icons.play_circle_fill,
//           color: Colors.greenAccent,
//           onPressed: onStartEvent ?? () {},
//         ),
//         const SizedBox(width: 14),
//       ],
//       _buildButton(
//         icon: Icons.call_end,
//         color: Colors.redAccent,
//         onPressed: onLeave,
//       ),
//     ];
//
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         color: Colors.black.withOpacity(0.4),
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//         child: isSmallScreen
//             ? Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: topRow,
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: bottomRow,
//             ),
//           ],
//         )
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [...topRow, const SizedBox(width: 14), ...bottomRow],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//     String? tooltip,
//   }) {
//     return Tooltip(
//       message: tooltip ?? '',
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(50),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.black54,
//           ),
//           child: Icon(icon, color: color, size: 26),
//         ),
//       ),
//     );
//   }
//
// }
import 'package:flutter/material.dart';

class MeetingPanel extends StatefulWidget {
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
  final VoidCallback onDescription;
  final bool isTranscriptionEnabled;
  final bool isCaptionsEnabled;
  final List<String> subtitles;
  final bool isChatOpen;
  final bool isParticipantsOpen;

  const MeetingPanel({
    super.key,
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
    required this.onDescription,
    required this.isHandRaised,
    required this.onToggleHand,
    required this.onTranscribeToggle,
    required this.onCaptionsToggle,
    required this.isTranscriptionEnabled,
    required this.isCaptionsEnabled,
    required this.subtitles,
    this.onStartEvent,
    this.onEndEvent,
    this.isChatOpen = false,
    this.isParticipantsOpen = false,
  });

  @override
  State<MeetingPanel> createState() => _MeetingPanelState();
}

class _MeetingPanelState extends State<MeetingPanel> {
  final ScrollController _subtitleController = ScrollController();

  @override
  void didUpdateWidget(covariant MeetingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tự động scroll xuống cuối mỗi khi subtitles thay đổi
    if (widget.subtitles.length != oldWidget.subtitles.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_subtitleController.hasClients) {
          _subtitleController.animateTo(
            _subtitleController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cột control icons
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: Icons.error_outline,
                      color: Colors.white,
                      onPressed: widget.onDescription,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: widget.isMicOn ? Icons.mic : Icons.mic_off,
                      color: widget.isMicOn ? Colors.white : Colors.redAccent,
                      onPressed: widget.onToggleMic,
                      disabled: widget.isChatOpen || widget.isParticipantsOpen,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: widget.isCameraOn ? Icons.videocam : Icons.videocam_off,
                      color: widget.isCameraOn ? Colors.white : Colors.redAccent,
                      onPressed: widget.onToggleCamera,
                      disabled: widget.isChatOpen || widget.isParticipantsOpen,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: widget.isTranscriptionEnabled
                          ? Icons.record_voice_over
                          : Icons.voice_over_off,
                      color: widget.isTranscriptionEnabled ? Colors.white : Colors.redAccent,
                      onPressed: widget.onTranscribeToggle,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: Icons.closed_caption,
                      color: Colors.white,
                      onPressed: widget.onCaptionsToggle,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: Icons.chat,
                      color: Colors.white,
                      onPressed: widget.onChatToggle,
                    ),
                    const SizedBox(height: 10),
                    if (!widget.isHost)
                      _buildButton(
                        icon: widget.isHandRaised ? Icons.back_hand : Icons.pan_tool_alt_outlined,
                        color: widget.isHandRaised ? Colors.amber : Colors.white,
                        onPressed: widget.onToggleHand,
                      ),
                    if (!widget.isHost) const SizedBox(height: 10),
                    _buildButton(
                      icon: Icons.people,
                      color: Colors.white,
                      onPressed: widget.onParticipants,
                    ),
                    const SizedBox(height: 10),
                    if (widget.isHost)
                      widget.hasStartedEvent
                          ? _buildButton(
                        icon: Icons.stop_circle,
                        color: Colors.redAccent,
                        onPressed: widget.onEndEvent ?? () {},
                      )
                          : _buildButton(
                        icon: Icons.play_circle_fill,
                        color: Colors.greenAccent,
                        onPressed: widget.onStartEvent ?? () {},
                      ),
                    if (widget.isHost) const SizedBox(height: 10),
                    _buildButton(
                      icon: Icons.call_end,
                      color: Colors.redAccent,
                      onPressed: widget.onLeave,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Cột subtitles
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ScrollConfiguration(
                    behavior: _NoGlowBehavior(),
                    child: ListView.builder(
                      controller: _subtitleController,
                      itemCount: widget.subtitles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.subtitles[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
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
    bool disabled = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[800] : Colors.black54,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

/// Tắt hiệu ứng scroll glow
class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
