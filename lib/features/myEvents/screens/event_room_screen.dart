
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/webrtc_controller.dart';

class MeetingRoomScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final bool isHost;
  final bool initialMicOn;
  final bool initialCameraOn;

  const MeetingRoomScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.isHost = false,
    this.initialMicOn = true,
    this.initialCameraOn = true,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final _localRenderer = RTCVideoRenderer();
  late final WebRTCController _controller;
  final _uuid = const Uuid();

  bool isLoading = true;
  bool isCameraOn = true;
  bool isMicOn = true;
  bool isParticipantsOpen = false;
  bool isSettingsOpen = false;
  bool hasStartedEvent = false;
  bool showLeaveDialog = false;
  bool showEndDialog = false;

  @override
  void initState() {
    super.initState();
    isCameraOn = widget.initialCameraOn;
    isMicOn = widget.initialMicOn;
    _controller = WebRTCController(
      eventId: widget.eventId,
      userName: widget.isHost ? "Host" : "Guest-${_uuid.v4().substring(0, 5)}",
      isHost: widget.isHost,
    );
    _initMeeting();
  }

  @override
  void dispose() {
    _cleanupMeeting();
    super.dispose();
  }

  Future<void> _cleanupMeeting() async {
    try {
      await _controller.leaveRoom();
      await _localRenderer.dispose();
    } catch (_) {}
  }

  Future<void> _initMeeting() async {
    await _localRenderer.initialize();

    try {
      // 1️⃣ Init WebRTC
      await _controller.initSignalR();
      await _controller.initLocalMedia();

      // 2️⃣ Gán local stream
      _localRenderer.srcObject = _controller.localStream;

      // 3️⃣ Join phòng
      await _controller.joinRoom();

      // 4️⃣ Nếu là host thì có thể start call ngay
      if (widget.isHost) {
        Future.delayed(const Duration(seconds: 1), () async {
          await _controller.startCall();
        });
      }

      setState(() => isLoading = false);

      // 5️⃣ Lắng nghe thay đổi participants
      _controller.addListener(() {
        if (mounted) setState(() {});
      });

    } catch (e) {
      _showSnack("Error initializing meeting: $e");
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _toggleAudio() async {
    await _controller.toggleAudio();
    setState(() => isMicOn = _controller.localAudioEnabled);
  }

  void _toggleVideo() async {
    await _controller.toggleVideo();
    setState(() => isCameraOn = _controller.localVideoEnabled);
  }

  void _toggleHand() {
    setState(() => _controller.participants[_controller.myConnectionId]?.isHandRaised =
    !(_controller.participants[_controller.myConnectionId]?.isHandRaised ?? false));
    _controller.notifyListeners();
  }

  void _handleLeave() async {
    await _cleanupMeeting();
    if (mounted) Navigator.pop(context);
  }

  void _handleStartEvent() async {
    if (!widget.isHost) return;
    setState(() => hasStartedEvent = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        _showSnack("Bạn chưa đăng nhập");
        setState(() => hasStartedEvent = false);
        return;
      }

      final eventRepository = EventRepository(EventService(ApiClient()));
      final updatedEvent = await eventRepository.updateEventStatus(
        token: token,
        eventId: widget.eventId,
        status: 'Live',
      );

      if (updatedEvent != null) {
        _showSnack("Event status updated to Live!");
        await _controller.startCall(); // ✅ host bắt đầu truyền tín hiệu
      } else {
        _showSnack("Failed to update event status.");
        setState(() => hasStartedEvent = false);
      }
    } catch (e) {
      _showSnack("Error updating event status: $e");
      setState(() => hasStartedEvent = false);
    }
  }

  void _handleEndEvent() async {
    if (!widget.isHost) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        _showSnack("Bạn chưa đăng nhập");
        return;
      }

      final eventRepository = EventRepository(EventService(ApiClient()));
      final updatedEvent = await eventRepository.updateEventStatus(
        token: token,
        eventId: widget.eventId,
        status: 'Completed',
      );

      if (updatedEvent != null) {
        _showSnack("Event ended and status updated to Completed!");
      } else {
        _showSnack("Failed to update event status.");
      }

      await _controller.leaveRoom();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack("Error ending event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final participantList = _controller.participants.values.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Khu vực video + overlay (participants list, settings, dialog)
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: VideoGrid(
                      eventTitle: widget.eventTitle,
                      localRenderer: _localRenderer,
                      participants: participantList,
                      isHost: widget.isHost,
                    ),
                  ),

                  // 🔸 ParticipantList (bottom sheet trồi lên)
                  if (isParticipantsOpen)
                    ParticipantList(
                      participants: participantList,
                      isHost: widget.isHost,
                      onClose: () => setState(() => isParticipantsOpen = false),
                    ),

                  // 🔸 Device Settings
                  if (isSettingsOpen)
                    DeviceSettings(
                        onClose: () => setState(() => isSettingsOpen = false)),

                  // 🔸 Leave / End dialogs
                  if (showLeaveDialog)
                    _buildConfirmDialog(
                      title: "Leave Meeting?",
                      message: "Are you sure you want to leave this meeting?",
                      confirmText: "Leave",
                      onConfirm: _handleLeave,
                      onCancel: () => setState(() => showLeaveDialog = false),
                    ),
                  if (showEndDialog)
                    _buildConfirmDialog(
                      title: "End Event?",
                      message: "This will end the meeting for all participants.",
                      confirmText: "End Event",
                      onConfirm: _handleEndEvent,
                      onCancel: () => setState(() => showEndDialog = false),
                    ),
                ],
              ),
            ),

            // 🔹 Thanh công cụ cố định ở dưới, không bị che
            MeetingControls(
              isHost: widget.isHost,
              isCameraOn: isCameraOn,
              isMicOn: isMicOn,
              isHandRaised: false,
              hasStartedEvent: hasStartedEvent,
              onToggleCamera: _toggleVideo,
              onToggleMic: _toggleAudio,
              onToggleHand: _toggleHand,
              onParticipants: () =>
                  setState(() => isParticipantsOpen = !isParticipantsOpen),
              onSettings: () =>
                  setState(() => isSettingsOpen = !isSettingsOpen),
              onLeave: () => setState(() => showLeaveDialog = true),
              onStartEvent: _handleStartEvent,
              onEndEvent: () => setState(() => showEndDialog = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Center(
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: onCancel, child: const Text("Cancel")),
          ElevatedButton(onPressed: onConfirm, child: Text(confirmText)),
        ],
      ),
    );
  }
}
/// --- VIDEO GRID (UI chuyên nghiệp hơn) ---
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

    // Host luôn là người đầu tiên
    final host = allParticipants.firstWhere(
          (p) => p.role == 'host' || p.id == 'local',
      orElse: () => allParticipants.first,
    );

    final others =
    allParticipants.where((p) => p.id != host.id).toList(growable: false);

    return Column(
      children: [
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

        // 🔹 Host video chiếm nửa màn hình
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _ParticipantCard(
              participant: host,
              isLarge: true,
            ),
          ),
        ),

        // 🔹 Hàng ngang người tham gia khác
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
                          child: _ParticipantCard(participant: p),
                        );
                      },
                    ),
                  ),
                  if (others.length > 4)
                    GestureDetector(
                      onTap: () {
                        // mở participant list (dựa vào state bên ngoài)
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
      ],
    );
  }
}

/// --- PARTICIPANT CARD ---
class _ParticipantCard extends StatefulWidget {
  final Participant participant;
  final bool isLarge;
  const _ParticipantCard({
    required this.participant,
    this.isLarge = false,
  });

  @override
  State<_ParticipantCard> createState() => _ParticipantCardState();
}

class _ParticipantCardState extends State<_ParticipantCard> {
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

/// --- MEETING CONTROLS (UI tách riêng, có shadow trên) ---
class MeetingControls extends StatelessWidget {
  final bool isHost, isCameraOn, isMicOn, isHandRaised, hasStartedEvent;
  final VoidCallback onToggleCamera,
      onToggleMic,
      onToggleHand,
      onParticipants,
      onSettings,
      onLeave,
      onStartEvent,
      onEndEvent;

  const MeetingControls({
    super.key,
    required this.isHost,
    required this.isCameraOn,
    required this.isMicOn,
    required this.isHandRaised,
    required this.hasStartedEvent,
    required this.onToggleCamera,
    required this.onToggleMic,
    required this.onToggleHand,
    required this.onParticipants,
    required this.onSettings,
    required this.onLeave,
    required this.onStartEvent,
    required this.onEndEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Colors.black26, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: isMicOn ? Icons.mic : Icons.mic_off,
              color: isMicOn ? Colors.white : Colors.redAccent,
              onPressed: onToggleMic,
            ),
            _buildControlButton(
              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
              color: isCameraOn ? Colors.white : Colors.redAccent,
              onPressed: onToggleCamera,
            ),
            _buildControlButton(
              icon: Icons.pan_tool,
              color: isHandRaised ? Colors.yellow : Colors.white,
              onPressed: onToggleHand,
            ),
            _buildControlButton(
              icon: Icons.people,
              color: Colors.white,
              onPressed: onParticipants,
            ),
            _buildControlButton(
              icon: Icons.settings,
              color: Colors.white,
              onPressed: onSettings,
            ),
            isHost
                ? ElevatedButton(
              onPressed:
              hasStartedEvent ? onEndEvent : onStartEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                hasStartedEvent ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
              ),
              child: Text(
                hasStartedEvent ? "End Event" : "Start Event",
                style: const TextStyle(color: Colors.white),
              ),
            )
                : _buildControlButton(
              icon: Icons.exit_to_app,
              color: Colors.redAccent,
              onPressed: onLeave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkResponse(
      onTap: onPressed,
      radius: 28,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

/// --- PARTICIPANT LIST (Bottom slide-up) ---
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
    final height = MediaQuery.of(context).size.height * 0.45; // chiếm 45% màn hình

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
            // 🔹 Header
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

            // 🔹 Danh sách người tham gia
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
                      child: const Icon(Icons.person,
                          color: Colors.white70),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      p.role,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!p.audioEnabled)
                          const Icon(Icons.mic_off,
                              color: Colors.red, size: 18),
                        if (!p.videoEnabled)
                          const Icon(Icons.videocam_off,
                              color: Colors.red, size: 18),
                        if (p.isHandRaised)
                          const Icon(Icons.pan_tool,
                              color: Colors.amber, size: 18),
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


/// --- DEVICE SETTINGS ---
class DeviceSettings extends StatelessWidget {
  final VoidCallback onClose;
  const DeviceSettings({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 20,
      width: 250,
      child: Material(
        color: Colors.white70,
        elevation: 5,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Device Settings"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(onPressed: onClose, icon: const Icon(Icons.close))
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Camera and microphone settings go here."),
            ),
          ],
        ),
      ),
    );
  }
}
