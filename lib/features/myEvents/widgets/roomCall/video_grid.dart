import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
    final allParticipants = [
      Participant(
        id: 'local',
        name: isHost ? 'Host' : 'You',
        role: isHost ? 'host' : 'local',
        stream: localRenderer.srcObject,
      ),
      ...participants,
    ];

    final host = allParticipants.firstWhere(
          (p) => p.role == 'host' || p.id == 'local',
      orElse: () => allParticipants.first,
    );

    final others = allParticipants
        .where((p) => p.id != host.id)
        .toList(growable: false);

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          color: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                eventTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Host video
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ParticipantCard(participant: host, isLarge: true),
          ),
        ),

        // Other participants
        if (others.isNotEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: others.length > 4 ? 4 : others.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final p = others[index];
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ParticipantCard(participant: p),
                        );
                      },
                    ),
                  ),
                  if (others.length > 4)
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mở danh sách người tham gia'),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${others.length - 4}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Khoảng trống tránh che bởi controls
        const SizedBox(height: kToolbarHeight + 20),
      ],
    );
  }
}

/// --- Participant Card ---
class ParticipantCard extends StatefulWidget {
  final Participant participant;
  final bool isLarge;

  const ParticipantCard({required this.participant, this.isLarge = false});

  @override
  State<ParticipantCard> createState() => _ParticipantCardState();
}

class _ParticipantCardState extends State<ParticipantCard> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void didUpdateWidget(covariant ParticipantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participant.stream != widget.participant.stream) {
      _renderer.srcObject = widget.participant.stream;
    }
  }

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (widget.participant.stream != null) {
      _renderer.srcObject = widget.participant.stream;
      print("[UI] Renderer initialized for ${widget.participant.name}");
    }
    if (mounted) setState(() {});
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

    if (_renderer.textureId != null &&
        _renderer.srcObject != p.stream &&
        hasVideo) {
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
