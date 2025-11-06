import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:polygo_mobile/features/myEvents/widgets/roomCall/participant_controls_dialog.dart';
import '../../../../data/services/webrtc_controller.dart';

class ParticipantList extends StatelessWidget {
  final List<Participant> participants;
  final bool isHost;
  final VoidCallback onClose;

  const ParticipantList({
    super.key,
    required this.participants,
    required this.isHost,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.45;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: height,
      child: Material(
        elevation: 16,
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Participants",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: participants.isEmpty
                  ? const Center(
                child: Text(
                  "No participants yet",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: participants.length,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemBuilder: (context, index) {
                  final p = participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!p.audioEnabled)
                          const Icon(Icons.mic_off, color: Colors.red, size: 18),
                        if (!p.videoEnabled)
                          const Icon(Icons.videocam_off, color: Colors.red, size: 18),
                        if (p.isHandRaised)
                          const Icon(Icons.pan_tool, color: Colors.amber, size: 18),
                        if (isHost)
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ParticipantControlsDialog(
                                  participant: p,
                                  initialMicEnabled: p.audioEnabled,
                                  initialCamEnabled: p.videoEnabled,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
