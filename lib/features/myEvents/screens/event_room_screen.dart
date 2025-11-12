import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/apis/event_service.dart';
import '../../../data/services/signalr/webrtc_controller.dart';
import '../../../routes/app_routes.dart';
import '../widgets/roomCall/chat_panel.dart';
import '../widgets/roomCall/meeting_controls.dart';
import '../widgets/roomCall/participant_list.dart';
import '../widgets/roomCall/video_grid.dart';

class MeetingRoomScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String eventStatus;
  final bool isHost;
  final bool initialMicOn;
  final bool initialCameraOn;
  final String hostId;

  const MeetingRoomScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventStatus,
    this.isHost = false,
    this.initialMicOn = true,
    this.initialCameraOn = true,
    required this.hostId,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  bool isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
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
  bool _chatListenerAdded = false;

  @override
  void initState() {
    super.initState();

    isCameraOn = widget.initialCameraOn;
    isMicOn = widget.initialMicOn;

    if (widget.isHost && widget.eventStatus.toLowerCase() == 'live') {
      hasStartedEvent = true;
    } else {}
    _controller = WebRTCController(
      eventId: widget.eventId,
      userName: widget.isHost ? "Host" : "Guest-${_uuid.v4().substring(0, 5)}",
      isHost: widget.isHost,
      localAudioEnabled: widget.initialMicOn,
      localVideoEnabled: widget.initialCameraOn,
      onRoomEnded: () {
        if (!widget.isHost && mounted) {
          final hostName = _controller.hostId != null
              ? _controller.participants[_controller.hostId!]?.name ?? "Host"
              : "Host";

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.endMeeting,
            arguments: {
              'eventId': widget.eventId,
              'eventName': widget.eventTitle,
              'hostName': _controller.participants[_controller.hostId!]?.name ?? 'Host',
            },
          );

        }
      },
    );
    _controller.onParticipantMuted = (participantId) {
      final p = _controller.participants[participantId];
      if (p != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${p.name} has been muted")),
        );
      }
    };

    _controller.onAllMuted = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All participants have been muted")),
        );
      }
    };

    _controller.onParticipantCameraOff = (participantId) {
      final p = _controller.participants[participantId];
      if (p != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${p.name}'s camera has been turned off")),
        );
      }
    };

    _controller.onAllCamsOff = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All participant cameras have been turned off")),
        );
      }
    };
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
      await _controller.initSignalR();

      if (!_chatListenerAdded) {
        _controller.addChatListener((msg) {
          if (mounted) {
            setState(() {
              // _chatMessages.add(msg);
            });
          }
        });
        _chatListenerAdded = true;
      }

      await _controller.initLocalMedia();
      isMicOn = _controller.localAudioEnabled;
      isCameraOn = _controller.localVideoEnabled;
      _localRenderer.srcObject = _controller.localStream;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        try {
          final user = await AuthRepository(AuthService(ApiClient())).me(token);
          _controller.userName = user.name;
        } catch (e) {
          print("Failed to get user info: $e");
        }
      }

      // Sử dụng widget.isHost để quyết định isHost khi joinRoom
      final isUserHost = widget.isHost;

      await _controller.joinRoom(
        isHost: isUserHost,
      );

      print("Controller hostId: ${_controller.hostId}");
      _controller.participants.forEach((k, v) {
        print("Participant: id=${v.id}, name=${v.name}, role=${v.role}");
      });

      if (isUserHost) {
        Future.delayed(const Duration(seconds: 1), () async {
          await _controller.startCall();
        });
      }

      setState(() => isLoading = false);
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
        await _controller.startCall();
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

      await _controller.endEvent();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.myEvents);
      }
    } catch (e) {
      _showSnack("Error ending event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Video & grid
            Positioned.fill(
              child: VideoGrid(
                eventTitle: widget.eventTitle,
                localRenderer: _localRenderer,
                participants: _controller.participants.values
                    .where((p) => p.id != _controller.myConnectionId)
                    .toList(),
                controller: _controller,
                widgetIsHost: widget.isHost,
              )
              ,
            ),

            // Participant list
            if (isParticipantsOpen)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return ParticipantList(
                    participants: _controller.participants.values
                        .where((p) => p.id != _controller.myConnectionId)
                        .toList(),
                    isHost: widget.isHost,
                    onClose: () => setState(() => isParticipantsOpen = false),
                    onMuteAll: () async {
                      await _controller.muteAllParticipants();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Muted all participants")),
                      );
                    },
                    onTurnOffAllCams: () async {
                      await _controller.turnOffAllParticipantCameras();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Turned off all cameras")),
                      );
                    },
                    controller: _controller,
                  );
                },
              ),

            // Chat panel
            if (isChatOpen) ...[
              AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              // Chat panel
              ChatPanel(
                messages: _controller.chatMessages,
                controller: _chatController,
                myName: _controller.userName,
                onSend: (text) async {
                  if (text.trim().isEmpty) return;
                  await _controller.sendChatMessage(text);
                },
                onClose: () => setState(() => isChatOpen = false),
              ),

            ],

            //  Leave / End dialogs
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

            // Meeting controls
            IgnorePointer(
              ignoring: isChatOpen || isParticipantsOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (isChatOpen || isParticipantsOpen) ? 0 : 1,
                child: MeetingControls(
                  isHost: widget.isHost,
                  isCameraOn: _controller.isVideoEnabled,
                  isMicOn: _controller.isAudioEnabled,
                  hasStartedEvent: hasStartedEvent,
                  onToggleCamera: _toggleVideo,
                  onToggleMic: _toggleAudio,
                  onChatToggle: () => setState(() => isChatOpen = !isChatOpen),
                  onParticipants: () =>
                      setState(() => isParticipantsOpen = !isParticipantsOpen),
                  onSettings: () =>
                      setState(() => isSettingsOpen = !isSettingsOpen),
                  onLeave: () => setState(() => showLeaveDialog = true),
                  onStartEvent: _handleStartEvent,
                  onEndEvent: () => setState(() => showEndDialog = true),
                ),
              ),
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