import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:polygo_mobile/features/myEvents/widgets/roomCall/participant_controls_dialog.dart';
import '../../../../data/services/webrtc_controller.dart';

class VideoGrid extends StatelessWidget {
  final String eventTitle;
  final RTCVideoRenderer localRenderer;
  final List<Participant> participants;
  final bool isHost;

  const VideoGrid({
    super.key,
    required this.localRenderer,
    required this.participants,
    required this.eventTitle,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final hostParticipant = Participant(
      id: 'local',
      name: isHost ? 'You (Host)' : 'You',
      role: 'host',
      stream: localRenderer.srcObject,
    );

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

        // Host video
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ParticipantCard(
              participant: hostParticipant,
              isLarge: true,
              isHost: isHost,
            ),
          ),
        ),

        // attendees
        if (participants.isNotEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: participants.length > 4 ? 4 : participants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final p = participants[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: ParticipantCard(
                      participant: p,
                      isHost: isHost,
                    ),
                  );
                },
              ),
            ),
          ),

        if (participants.length > 4)
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
                '+${participants.length - 4}',
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
  }
}
/// --- Participant Card ---
class ParticipantCard extends StatefulWidget {
  final Participant participant;
  final bool isLarge;
  final bool isHost;

  const ParticipantCard({
    required this.participant,
    this.isLarge = false,
    this.isHost = false,
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
          hasVideo && _renderer.textureId != null
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
          if (widget.isHost != false)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ParticipantControlsDialog(
                      participant: widget.participant,
                      initialMicEnabled: true,
                      initialCamEnabled: false,
                    ),
                  );
                },
              ),
            ),
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
              child: Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showParticipantControls(BuildContext context, Participant participant) {
  bool micEnabled = true;
  bool camEnabled = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Controls for ${participant.name}"),
            content: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Mic row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.mic, color: Colors.black87),
                          SizedBox(width: 8),
                          Text("Mic"),
                        ],
                      ),
                      Switch(
                        value: micEnabled,
                        onChanged: (v) => setState(() => micEnabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Cam row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.videocam, color: Colors.black87),
                          SizedBox(width: 8),
                          Text("Camera"),
                        ],
                      ),
                      Switch(
                        value: camEnabled,
                        onChanged: null, // disabled
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}

