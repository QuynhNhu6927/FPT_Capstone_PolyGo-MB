import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../data/services/signalr/webrtc_controller.dart';

class VideoGrid extends StatelessWidget {
  final String eventTitle;
  final RTCVideoRenderer localRenderer;
  final List<Participant> participants;
  final WebRTCController controller;
  final bool widgetIsHost;

  const VideoGrid({
    super.key,
    required this.localRenderer,
    required this.participants,
    required this.eventTitle,
    required this.controller,
    required this.widgetIsHost,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final localParticipant = Participant(
          id: 'local',
          name: widgetIsHost ? 'You (Host)' : 'You',
          role: 'host',
          stream: controller.localStream,
          audioEnabled: controller.localAudioEnabled,
          videoEnabled: controller.localVideoEnabled,
        );

        // --- Phân loại host và các participant khác ---
        final allParticipants = [...participants, localParticipant];

        // Tìm host dựa trên hostId
        final hostParticipant = allParticipants.firstWhere(
              (p) => p.id == controller.hostId || p.role == 'host',
          orElse: () => localParticipant,
        );

        // Các participant còn lại
        final otherParticipants =
        allParticipants.where((p) => p.id != hostParticipant.id).toList();

        // --- LOG ---
        print("=== Participants List Updated ===");
        print("Local user is host? ${widgetIsHost}, controller.hostId=${controller.hostId}");
        for (var p in allParticipants) {
          print("Participant id=${p.id}, name=${p.name}, role=${p.role}");
        }
        print("===============================");

        return Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                eventTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Video lớn nhất là host
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ParticipantCard(
                  participant: hostParticipant,
                  isLarge: true,
                  isHost: true,
                  onSwitchCamera: () => controller.switchCamera(),
                ),
              ),
            ),

            // Các participant còn lại (nhỏ)
            if (otherParticipants.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: otherParticipants.length > 4 ? 4 : otherParticipants.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final p = otherParticipants[index];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ParticipantCard(
                          participant: p,
                          isLarge: false,
                          isHost: p.id == controller.hostId,
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (otherParticipants.length > 4)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+${otherParticipants.length - 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: kToolbarHeight + 20),
          ],
        );
      },
    );
  }
}

/// --- Participant Card ---
  class ParticipantCard extends StatefulWidget {
    final Participant participant;
    final bool isLarge;
    final bool isHost;
    final VoidCallback? onSwitchCamera;

  const ParticipantCard({
    required this.participant,
    this.isLarge = false,
    this.isHost = false,
    this.onSwitchCamera,
  });

  @override
  State<ParticipantCard> createState() => _ParticipantCardState();
}

class _ParticipantCardState extends State<ParticipantCard> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (widget.participant.stream != null) {
      _renderer.srcObject = widget.participant.stream;
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant ParticipantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participant.stream != widget.participant.stream) {
      _renderer.srcObject = widget.participant.stream;
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final p = widget.participant;
    final hasVideo = p.stream != null;

    if (_renderer.textureId != null && _renderer.srcObject != p.stream && hasVideo) {
      _renderer.srcObject = p.stream;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video / Placeholder
          (_renderer.textureId != null && p.videoEnabled == true && p.stream != null)
              ? RTCVideoView(
            _renderer,
            mirror: p.role == 'local',
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
              : Container(
            color: Colors.grey.shade700,
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              size: widget.isLarge ? 100 : 50,
              color: Colors.white54,
            ),
          ),
          // Name + icons
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (p.audioEnabled != null)
                    Icon(
                      p.audioEnabled! ? Icons.mic : Icons.mic_off,
                      color: p.audioEnabled! ? Colors.white : Colors.redAccent,
                      size: 20,
                    ),
                  const SizedBox(width: 4),
                  if (p.videoEnabled != null)
                    Icon(
                      p.videoEnabled! ? Icons.videocam : Icons.videocam_off,
                      color: p.videoEnabled! ? Colors.white : Colors.redAccent,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          if ((p.id == 'local' || widget.isHost) && p.videoEnabled)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onSwitchCamera,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

  }

}
