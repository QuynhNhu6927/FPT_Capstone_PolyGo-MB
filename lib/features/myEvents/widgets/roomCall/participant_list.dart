// participant_list.dart
import 'package:flutter/material.dart';
import '../../../../data/services/signalr/webrtc_controller.dart';
import 'participant_controls_dialog.dart';

class ParticipantList extends StatefulWidget {
  final List<Participant> participants;
  final bool isHost;
  final VoidCallback onClose;
  final Future<void> Function()? onMuteAll;
  final Future<void> Function()? onTurnOffAllCams;
  final WebRTCController? controller;

  const ParticipantList({
    super.key,
    required this.participants,
    required this.isHost,
    required this.onClose,
    this.onMuteAll,
    this.onTurnOffAllCams,
    this.controller,
  });

  @override
  State<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.45;
    final theme = Theme.of(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: height,
      child: Material(
        elevation: 16,
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Participants",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Host controls
            if (widget.isHost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.onMuteAll != null) await widget.onMuteAll!();
                        setState(() {});
                      },
                      child: const Text("Mute All"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.onTurnOffAllCams != null) await widget.onTurnOffAllCams!();
                        setState(() {});
                      },
                      child: const Text("Turn Off All Cameras"),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),

            // Participant list
            Expanded(
              child: widget.participants.isEmpty
                  ? Center(
                child: Text(
                  "No participants yet",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: widget.participants.length,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemBuilder: (context, index) {
                  final p = widget.participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.dividerColor,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          p.audioEnabled ? Icons.mic : Icons.mic_off,
                          color: p.audioEnabled ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          p.videoEnabled ? Icons.videocam : Icons.videocam_off,
                          color: p.videoEnabled ? Colors.green : Colors.red,
                          size: 18,
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
