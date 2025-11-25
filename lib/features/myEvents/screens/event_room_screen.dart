import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
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
  bool isHandRaised = false;

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
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${p.name} ${loc.translate('mic_has_been_muted')}")),
        );
      }
    };

    _controller.onAllMuted = () {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("all_mic_muted"))),
        );
      }
    };

    _controller.onParticipantCameraOff = (participantId) {
      final p = _controller.participants[participantId];
      if (p != null && mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${p.name}'s ${loc.translate('camera_has_been_muted')}")),
        );
      }
    };

    _controller.onAllCamsOff = () {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("all_cam_muted"))),
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

      final prefs2 = await SharedPreferences.getInstance();
      final token2 = prefs2.getString('token');
      String? userId;

      if (token2 != null && token2.isNotEmpty) {
        try {
          final me = await AuthRepository(AuthService(ApiClient())).me(token2);
          userId = me.id;
        } catch (e) {
          //
        }
      }

      if (userId != null) {
        final ok = await _controller.joinRoomConfirm(userId);
      }

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
      //
    }
  }

  void _toggleHand() async {
    if (isHandRaised) {
      await _controller.unwave();
    } else {
      await _controller.sendWave();
    }

    setState(() {
      isHandRaised = !isHandRaised;
    });
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
    final loc = AppLocalizations.of(context);
    setState(() => hasStartedEvent = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        _showSnack(loc.translate("missing_token"));
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
        _showSnack(loc.translate('event_status_update_live'));
        await _controller.startCall();
      } else {
        _showSnack(loc.translate('event_status_update_failed'));
        setState(() => hasStartedEvent = false);
      }
    } catch (e) {
      _showSnack(loc.translate('event_status_update_failed'));
      setState(() => hasStartedEvent = false);
    }
  }

  void _handleEndEvent() async {
    if (!widget.isHost) return;
    final loc = AppLocalizations.of(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        _showSnack(loc.translate("missing_token"));
        return;
      }

      final eventRepository = EventRepository(EventService(ApiClient()));
      final updatedEvent = await eventRepository.updateEventStatus(
        token: token,
        eventId: widget.eventId,
        status: 'Completed',
      );

      if (updatedEvent != null) {
        _showSnack(loc.translate('event_status_update_completed'));
      } else {
        _showSnack(loc.translate('event_status_update_failed'));
      }

      await _controller.endEvent();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.myEvents);
      }
    } catch (e) {
      _showSnack(loc.translate('event_status_update_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final loc = AppLocalizations.of(context);

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
                        SnackBar(content: Text(loc.translate("all_mic_muted"))),
                      );
                    },
                    onTurnOffAllCams: () async {
                      await _controller.turnOffAllParticipantCameras();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.translate("all_cam_muted"))),
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
                title: loc.translate('confirm_leaving_call_title'),
                message: loc.translate('confirm_leaving_call'),
                confirmText: loc.translate('leave'),
                onConfirm: _handleLeave,
                onCancel: () => setState(() => showLeaveDialog = false),
                loc: loc,
              ),
            if (showEndDialog)
              _buildConfirmDialog(
                title: loc.translate('confirm_end_call_title'),
                message: loc.translate('confirm_end_call'),
                confirmText: loc.translate('end'),
                onConfirm: _handleEndEvent,
                onCancel: () => setState(() => showEndDialog = false),
                loc: loc,
              ),

            // Meeting controls
            IgnorePointer(
              ignoring: isChatOpen || isParticipantsOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (isChatOpen || isParticipantsOpen) ? 0 : 1,
                child: MeetingControls(
                  isHandRaised: isHandRaised,
                  onToggleHand: _toggleHand,
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
    required AppLocalizations loc,
  }) {
    return Center(
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: onCancel, child: Text(loc.translate('cancel'))),
          ElevatedButton(onPressed: onConfirm, child: Text(confirmText)),
        ],
      ),
    );
  }
}