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
import '../widgets/roomCall/event_room_intro.dart';
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
  final String sourceLanguage;
  final String? localAvatarUrl;

  const MeetingRoomScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventStatus,
    this.isHost = false,
    this.initialMicOn = true,
    this.initialCameraOn = true,
    required this.hostId,
    required this.sourceLanguage,
    this.localAvatarUrl,
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
  bool showControls = true;

  int controlPage = 0; // 0 = Controls, 1 = Subtitle
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    print("🔹 MeetingRoomScreen localAvatarUrl: ${widget.localAvatarUrl}");
    isCameraOn = widget.initialCameraOn;
    isMicOn = widget.initialMicOn;

    final normalizedSourceLang =
        languageCodeMap[widget.sourceLanguage] ?? widget.sourceLanguage;

    if (widget.isHost && widget.eventStatus.toLowerCase() == 'live') {
      hasStartedEvent = true;
    } else {}
    _controller = WebRTCController(
      eventId: widget.eventId,
      userName: widget.isHost ? "Host" : "Guest-${_uuid.v4().substring(0, 5)}",
      isHost: widget.isHost,
      localAudioEnabled: widget.initialMicOn,
      localVideoEnabled: widget.initialCameraOn,
      sourceLanguage: normalizedSourceLang,
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

    _controller.onKicked = (message) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      showDialog(
        context: context,
        barrierDismissible: true,  // user có thể bấm back
        builder: (_) => WillPopScope(
          onWillPop: () async {
            // Khi user bấm Back → thoát khỏi call
            Navigator.pop(context);  // đóng dialog
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.myEvents,
                  (route) => false,
            );
            return false; // ngăn dialog tự đóng mặc định
          },
          child: AlertDialog(
            title: Text(loc.translate('you_have_been_kicked_from_room')),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);  // đóng dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.myEvents,
                        (route) => false,
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    };
    _initMeeting();
  }

  Future<void> _showSubtitleLanguageDialog() async {
    String currentLang = _controller.targetLanguage;
    final loc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('setting_subtitle')),
          content: SizedBox(
            height: 250,
            width: double.maxFinite,
            child: ListView(
              children: subtitleLanguages.entries.map((entry) {
                final isCurrent = currentLang == entry.key;

                return ListTile(
                  title: Text(entry.value),
                  trailing: isCurrent ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _controller.setTargetLanguage(entry.key);
                    setState(() {}); // Nếu cần cập nhật UI
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // Luôn bật captions
    if (!_controller.isCaptionsEnabled) {
      _controller.enableCaptions();
    }
  }

  Future<void> _showTranscriptionDialog() async {
    bool transcriptionEnabled = _controller.isTranscriptionEnabled;
    String currentLang = _controller.sourceLanguage;
    final loc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(loc.translate('setting_voice_to_text')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle transcription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.translate('toggle_transcript')),
                      Switch(
                        value: transcriptionEnabled,
                        onChanged: (value) {
                          setStateDialog(() {
                            transcriptionEnabled = value;
                          });

                          if (value) {
                            _controller.enableMobileTranscription(currentLang);
                          } else {
                            _controller.disableMobileTranscription();
                          }

                          setState(() {});
                        },
                      ),
                    ],
                  ),

                  const Divider(),

                  // List languages (disabled when transcription OFF)
                  SizedBox(
                    height: 250,
                    width: double.maxFinite,
                    child: ListView(
                      children: languageCodeMap.entries.map((entry) {
                        final code = entry.key;
                        final locale = entry.value;
                        final isCurrent = locale == currentLang;

                        return ListTile(
                          enabled: transcriptionEnabled,
                          title: Text(
                            "$code (${locale.toUpperCase()})",
                            style: TextStyle(
                              color: transcriptionEnabled ? null : Colors.grey,
                            ),
                          ),
                          trailing: isCurrent && transcriptionEnabled
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: transcriptionEnabled
                              ? () {
                            Navigator.pop(context);
                            _controller.sourceLanguage = locale;
                            if (transcriptionEnabled) {
                              _controller.enableMobileTranscription(locale);
                            }
                            setState(() {});
                          }
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          if (mounted) setState(() {});
        });
        _chatListenerAdded = true;
      }

      await _controller.initLocalMedia();
      isMicOn = _controller.localAudioEnabled;
      isCameraOn = _controller.localVideoEnabled;
      _localRenderer.srcObject = _controller.localStream;

      // ---- CHỈ LẤY USER MỘT LẦN ----
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      String? userId;
      if (token != null && token.isNotEmpty) {
        try {
          final user = await AuthRepository(AuthService(ApiClient())).me(token);
          _controller.userName = user.name;
          userId = user.id;
        } catch (e) {
          print("Failed to get user info: $e");
        }
      }

      // ---- JOIN ROOM ----
      await _controller.joinRoom(
        isHost: widget.isHost,
        userId: userId,
      );

      // ---- LOAD CHAT HISTORY ----
      await _controller.loadChatHistory();

      print("Controller hostId: ${_controller.hostId}");
      _controller.participants.forEach((k, v) {
        print("Participant: id=${v.id}, name=${v.name}, role=${v.role}");
      });

      // ---- CONFIRM ----
      if (userId != null) {
        await _controller.joinRoomConfirm(userId);
      }

      // ---- HOST START CALL ----
      if (widget.isHost) {
        Future.delayed(const Duration(seconds: 1), () async {
          await _controller.startCall();
        });
      }

      setState(() => isLoading = false);
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      print("InitMeeting error: $e");
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

  void _showEventIntro() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => EventRoomIntro(eventId: widget.eventId),
    );
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

  Future<void> _handleEndEvent() async {
    if (!widget.isHost) return;
    final loc = AppLocalizations.of(context);

    try {
      await _controller.endEvent();

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

      // () async {
      //   try {
      //     await eventRepository.generateSummary(
      //       token: token,
      //       eventId: widget.eventId,
      //     );
      //   } catch (_) {}
      // }();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.myEvents);
      }

    } catch (e) {
      final raw = e.toString();
      String cleaned = raw;

      final marker = "Please wait at least";
      if (raw.contains(marker)) {
        cleaned = raw.substring(raw.indexOf(marker));
      } else {
        cleaned = raw.replaceAll("Exception:", "");
      }

      _showSnack(cleaned.trim());
      rethrow;
    }

  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final loc = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main layout: VideoGrid + Subtitle + Controls
            Column(
              children: [
                // VideoGrid chiếm tất cả không gian còn lại
                Expanded(
                  child: VideoGrid(
                    eventTitle: widget.eventTitle,
                    localRenderer: _localRenderer,
                    participants: _controller.participants.values
                        .where((p) => p.id != _controller.myConnectionId)
                        .toList(),
                    controller: _controller,
                    widgetIsHost: widget.isHost,
                    localAvatarUrl: widget.localAvatarUrl,
                  ),
                ),

                // Subtitle
                Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        showControls ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() => showControls = !showControls);
                      },
                    ),
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showControls
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IgnorePointer(
                      ignoring: isChatOpen || isParticipantsOpen,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (isChatOpen || isParticipantsOpen) ? 0 : 1,
                        child: MeetingPanel(
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
                          onDescription: _showEventIntro,
                          onLeave: () => setState(() => showLeaveDialog = true),
                          onStartEvent: _handleStartEvent,
                          onEndEvent: () => setState(() => showEndDialog = true),
                          onTranscribeToggle: _showTranscriptionDialog,
                          onCaptionsToggle: _showSubtitleLanguageDialog,
                          isTranscriptionEnabled: _controller.isTranscriptionEnabled,
                          isCaptionsEnabled: _controller.isCaptionsEnabled,
                          subtitles: _controller.transcriptions
                              .map((t) => "${t.senderName}: ${t.translatedText}")
                              .toList(),
                        )
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),

            // Overlays: participant list, chat, dialogs
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

            if (isChatOpen) ...[
              AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              ChatPanel(
                messages: _controller.chatMessages,
                controller: _chatController,
                myName: _controller.userName,
                onSend: (text) async {
                  if (text.trim().isEmpty) return;

                  if (!_controller.isChatEnabled) {
                    setState(() => isChatOpen = false);

                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate("chat_banned")),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    });

                    return;
                  }

                  await _controller.sendChatMessage(text);
                },

                onClose: () => setState(() => isChatOpen = false),
              ),
            ],

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
                // onConfirm: _handleEndEvent,
                onConfirm: () async {
                  try {
                    await _handleEndEvent();
                  } catch (_) {
                    //
                  }

                  if (mounted) {
                    setState(() => showEndDialog = false);
                  }
                },
                onCancel: () => setState(() => showEndDialog = false),
                loc: loc,
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

  final Map<String, String> subtitleLanguages = {
    'en': "English",
    'vi': "Tiếng Việt",
    'es': "Español",
    'fr': "Français",
    'de': "Deutsch",
    'ja': "日本語",
    'ko': "한국어",
    'zh': "中文",
    'ar': "العربية",
    'ru': "Русский",
    'pt': "Português",
    'it': "Italiano",
    'th': "ไทย",
  };
}

const Map<String, String> languageCodeMap = {
  "en": "en-US",
  "vi": "vi-VN",
  "ja": "ja-JP",
  "ko": "ko-KR",
  "zh": "zh-CN",
  "fr": "fr-FR",
  "de": "de-DE",
  "es": "es-ES",
  "it": "it-IT",
  "pt": "pt-BR",
  "ru": "ru-RU",
  "th": "th-TH",
  "id": "id-ID",
  "ms": "ms-MY",
  "ar": "ar-SA",
  "hi": "hi-IN",
};
