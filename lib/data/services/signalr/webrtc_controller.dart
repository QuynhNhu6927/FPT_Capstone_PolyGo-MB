import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../repositories/auth_repository.dart';
import '../apis/auth_service.dart';

class Participant {
  final String id;
  final String name;
  String role;
  MediaStream? stream;
  bool audioEnabled;
  bool videoEnabled;
  bool isHandRaised;

  Participant({
    required this.id,
    required this.name,
    required this.role,
    this.stream,
    this.audioEnabled = true,
    this.videoEnabled = true,
    this.isHandRaised = false,
  });
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class WebRTCController extends ChangeNotifier {
  final List<ValueChanged<ChatMessage>> _chatListeners = [];
  final Map<String, RTCPeerConnection> _peerConnections = {};
  List<ChatMessage> chatMessages = [];
  final String eventId;
  String userName;
  final bool isHost;

  final VoidCallback? onRoomEnded;
  HubConnection? _hub;
  bool isConnected = false;
  String? myConnectionId;
  String? hostId;

  Map<String, Participant> participants = {};
  MediaStream? localStream;
  bool localAudioEnabled;
  bool localVideoEnabled;
  bool get isAudioEnabled => localAudioEnabled;
  bool get isVideoEnabled => localVideoEnabled;
  ValueChanged<String>? onParticipantMuted;
  ValueChanged<String>? onParticipantCameraOff;
  VoidCallback? onAllMuted;
  VoidCallback? onAllCamsOff;

  WebRTCController({
    required this.eventId,
    required this.userName,
    required this.isHost,
    this.localAudioEnabled = true,
    this.localVideoEnabled = true,
    this.onRoomEnded,
  });

  Future<void> initLocalMedia() async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '24',
          },
          'facingMode': 'user',
          'optional': [],
        },
      };

      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localStream?.getAudioTracks().forEach((t) => t.enabled = localAudioEnabled);
      localStream?.getVideoTracks().forEach((t) => t.enabled = localVideoEnabled);
      notifyListeners();
    } catch (e) {
      //
    }
  }

  Future<void> switchCamera() async {
    if (localStream == null) return;

    // Lấy track video đầu tiên
    final videoTrack = localStream!.getVideoTracks().isNotEmpty
        ? localStream!.getVideoTracks().first
        : null;
    if (videoTrack == null) return;

    try {
      await videoTrack.switchCamera();
      print("🎥 Switched camera");
    } catch (e) {
      print("Error switching camera: $e");
    }
  }

  Future<RTCPeerConnection> createPeer(String remoteId) async {
    if (_peerConnections.containsKey(remoteId)) {
      return _peerConnections[remoteId]!;
    }

    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': [
            'turn:160.25.81.144:3478',
            'turn:160.25.81.144:3478?transport=tcp',
            'turn:160.25.81.144:5349?transport=tcp',
          ],
          'username': 'polygo',
          'credential': 'polygo2024',
        },
      ],
      'sdpSemantics': 'unified-plan',
    };

    final pc = await createPeerConnection(config);

    if (localStream != null) {
      for (var track in localStream!.getTracks()) {
        await pc.addTrack(track, localStream!);
      }
    }

    pc.onIceCandidate = (RTCIceCandidate candidate) async {
      if (candidate.candidate == null) return;
      final candidateJson = jsonEncode({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });

      try {
        await _hub?.invoke(
          "SendIceCandidate",
          args: [eventId, remoteId, candidateJson],
        );
      } catch (e) {
        //
      }
    };

    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams.first;
        participants.putIfAbsent(
          remoteId,
              () => Participant(
            id: remoteId,
            name: "Guest-$remoteId",
            role: "attendee",
          ),
        );
        participants[remoteId]!.stream = stream;
        notifyListeners();
      }
    };

    _peerConnections[remoteId] = pc;
    return pc;
  }

  Future<void> initSignalR() async {
    final hubUrl = '${ApiConstants.baseUrl}/eventRoomHub';
    _hub = HubConnectionBuilder().withUrl(hubUrl).withAutomaticReconnect().build();

    _hub!.onclose((error) {});
    _hub!.onreconnecting((error) {});
    _hub!.onreconnected((connectionId) {});

    // trong WebRTCController
    _hub!.on('SetRole', (args) async {
      myConnectionId = args?[1];
      hostId = args?[2];

      if (myConnectionId != null && localStream != null) {
        // Broadcast trạng thái ban đầu khi đã có connectionId
        try {
          await _hub!.invoke("BroadcastMediaState", args: [
            eventId,
            myConnectionId,
            "audio",
            localAudioEnabled,
          ]);
          await _hub!.invoke("BroadcastMediaState", args: [
            eventId,
            myConnectionId,
            "video",
            localVideoEnabled,
          ]);
        } catch (e) {
          if (kDebugMode) print("Failed to broadcast initial media state: $e");
        }
      }
    });


    _hub!.on('UserJoined', (args) async {
      final name = args?[0] ?? "Unknown";
      final connId = args?[2];

      // Giả lập trạng thái audio/video là false ban đầu
      participants[connId] = Participant(
        id: connId,
        name: name,
        role: connId == hostId ? "host" : "attendee",
        audioEnabled: localVideoEnabled,
        videoEnabled: localAudioEnabled,
      );
      notifyListeners();

      // Log trạng thái ban đầu
      if (connId != myConnectionId) {
        final p = participants[connId]!;
        print(
            "[Participant Joined] id=${p.id}, name=${p.name}, "
                "audio=${p.audioEnabled}, video=${p.videoEnabled}, role=${p.role}"
        );
      }

      if (connId != myConnectionId) {
        final pc = await createPeer(connId);
        final offer = await pc.createOffer();
        await pc.setLocalDescription(RTCSessionDescription(offer.sdp!, 'offer'));
        await _hub?.invoke("SendOffer", args: [eventId, connId, offer.sdp]);
      }
    });


    _hub!.on('ReceiveMediaState', (args) {
      final fromConnId = args?[0];
      final type = args?[1];
      final enabled = args?[2];

      if (fromConnId != null && participants.containsKey(fromConnId)) {
        final p = participants[fromConnId]!;

        if (type == 'audio') {
          p.audioEnabled = enabled;
        } else if (type == 'video') {
          p.videoEnabled = enabled;
        }

        // Log khi có update trạng thái audio/video
        print(
            "[Participant Update] id=${p.id}, name=${p.name}, "
                "audio=${p.audioEnabled}, video=${p.videoEnabled}, role=${p.role}"
        );

        notifyListeners();
      }
    });


    _hub!.on('UserLeft', (args) {
      final connId = args?[0];
      participants.remove(connId);
      notifyListeners();
    });

    _hub!.on('ReceiveChatMessage', (args) {
      final sender = args?[0] ?? "Unknown";
      final message = args?[1] ?? "";
      final chatMessage = ChatMessage(sender: sender, message: message);
      chatMessages.add(chatMessage);
      for (var listener in _chatListeners) {
        listener(chatMessage);
      }
      notifyListeners();
    });

    _hub!.on("ToggleMicCommand", (args) {
      final enabled = args?[0] ?? true;
      print("🎤 Received ToggleMicCommand: $enabled");

      localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
      localAudioEnabled = enabled;
      notifyListeners();
    });

    _hub!.on("ToggleCamCommand", (args) {
      final enabled = args?[0] ?? true;
      print("🎥 Received ToggleCamCommand: $enabled");

      localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);
      localVideoEnabled = enabled;
      notifyListeners();
    });


    _hub!.on('ReceiveOffer', (args) async {
      final fromConnId = args?[0];
      final sdp = args?[1];

      final pc = await createPeer(fromConnId);
      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _hub?.invoke("SendAnswer", args: [eventId, fromConnId, answer.sdp]);
    });

    _hub!.on('ReceiveAnswer', (args) async {
      final fromConnId = args?[0];
      final sdp = args?[1];

      final pc = _peerConnections[fromConnId];
      if (pc == null) return;

      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
    });

    _hub!.on('RoomEnded', (args) async {
      await leaveRoom();
      if (onRoomEnded != null) onRoomEnded!();
    });

    _hub!.on('ReceiveIceCandidate', (args) async {
      final fromConnId = args?[0];
      final candidateJson = args?[1];
      final data = jsonDecode(candidateJson);
      final pc = _peerConnections[fromConnId];
      if (pc == null) return;

      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await pc.addCandidate(candidate);
    });

    // Khi người khác wave
    _hub!.on("ReceiveWave", (args) {
      final connId = args?[0];
      final name = args?[1];

      if (connId != null && participants.containsKey(connId)) {
        participants[connId]!.isHandRaised = true;
        print("🙋 $name ($connId) waved");
        notifyListeners();
      }
    });

// Khi người khác unwave
    _hub!.on("ReceiveUnwave", (args) {
      final connId = args?[0];

      if (connId != null && participants.containsKey(connId)) {
        participants[connId]!.isHandRaised = false;
        print("✋ User $connId unwaved");
        notifyListeners();
      }
    });

// Khi bị host kick
    _hub!.on("KickedFromRoom", (args) async {
      final room = args?[0];
      print("❌ You were kicked from room: $room");

      // Tự rời room
      await leaveRoom();
    });

    await _hub!.start();
    isConnected = true;
  }

  Future<void> joinRoom({required bool isHost}) async {
    if (_hub == null || !isConnected) return;

    String actualName = userName;

    await _hub!.invoke("JoinRoom", args: [eventId, actualName, isHost]);

    if (localStream != null) {
      localAudioEnabled = localStream!.getAudioTracks().isNotEmpty
          ? localStream!.getAudioTracks().first.enabled
          : localAudioEnabled;
      localVideoEnabled = localStream!.getVideoTracks().isNotEmpty
          ? localStream!.getVideoTracks().first.enabled
          : localVideoEnabled;

      try {
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "audio",
          localAudioEnabled,
        ]);
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "video",
          localVideoEnabled,
        ]);
      } catch (e) {
        if (kDebugMode) print("Failed to broadcast initial media state: $e");
      }
    }

    try {
      final result = await _hub!.invoke("GetParticipants", args: [eventId]);
      if (result is Map) {
        result.forEach((id, name) {
          if (id != myConnectionId) {
            participants[id] = Participant(
              id: id,
              name: name,
              role: id == hostId ? "host" : "attendee",
            );
          }
        });
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Failed to get participants: $e");
    }
  }

  Future<void> startCall() async {
    if (participants.isEmpty) return;

    for (final remoteId in participants.keys) {
      if (remoteId == myConnectionId) continue;

      final pc = await createPeer(remoteId);

      final offer = await pc.createOffer();
      String modifiedSdp = _preferH264(offer.sdp!);
      await pc.setLocalDescription(RTCSessionDescription(modifiedSdp, 'offer'));
      await _hub?.invoke("SendOffer", args: [eventId, remoteId, modifiedSdp]);
    }
  }

  Future<bool> joinRoomConfirm(String userId) async {
    if (_hub == null || !isConnected) {
      return false;
    }
    try {
      await _hub!.invoke(
        "JoinRoomConfirm",
        args: [
          eventId,
          userId,
        ],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendWave() async {
    if (_hub == null || !isConnected) return;

    try {
      await _hub!.invoke("SendWave", args: [eventId]);
      print("🙋 Sent Wave");
    } catch (e) {
      print("Error sending wave: $e");
    }
  }

  Future<void> unwave() async {
    if (_hub == null || !isConnected) return;

    try {
      await _hub!.invoke("Unwave", args: [eventId]);
      print("✋ Sent Unwave");
    } catch (e) {
      print("Error sending unwave: $e");
    }
  }

// =========================
// KICK USER (HOST ONLY)
// =========================
  Future<void> kickUser(String targetConnId) async {
    if (!isHost) {
      print("❌ Only host can kick user");
      return;
    }

    if (_hub == null || !isConnected) return;

    try {
      await _hub!.invoke("KickUser", args: [eventId, targetConnId]);
      print("🚫 Host kicked: $targetConnId");
    } catch (e) {
      print("Error kicking user: $e");
    }
  }

  Future<void> toggleAudio({bool? initial}) async {
    final audioTrack = localStream?.getAudioTracks().isNotEmpty == true
        ? localStream!.getAudioTracks().first
        : null;
    if (audioTrack == null) return;

    if (initial != null) {
      audioTrack.enabled = initial;
    } else {
      audioTrack.enabled = !audioTrack.enabled;
    }
    localAudioEnabled = audioTrack.enabled;

    // Broadcast trạng thái audio mới
    if (_hub != null && myConnectionId != null) {
      try {
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "audio",
          localAudioEnabled
        ]);
      } catch (_) {}
    }
  }

  Future<void> toggleVideo({bool? initial}) async {
    final videoTrack = localStream?.getVideoTracks().isNotEmpty == true
        ? localStream!.getVideoTracks().first
        : null;
    if (videoTrack == null) return;

    if (initial != null) {
      videoTrack.enabled = initial;
    } else {
      videoTrack.enabled = !videoTrack.enabled;
    }
    localVideoEnabled = videoTrack.enabled;

    // Broadcast trạng thái video mới
    if (_hub != null && myConnectionId != null) {
      try {
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "video",
          localVideoEnabled
        ]);
      } catch (_) {}
    }
  }

  Future<void> toggleParticipantAudio(String participantId, bool enabled) async {
    if (_hub == null) return;

    try {
      if (participants.containsKey(participantId)) {
        participants[participantId]!.audioEnabled = enabled;
        notifyListeners();
      }

      await _hub!.invoke("ToggleMic", args: [
        eventId, // roomId
        participantId, // targetConnId
        enabled, // false để tắt mic
      ]);
      if (!enabled) {
        onParticipantMuted?.call(participantId);
      }

      print("🎤 Sent ToggleMic to $participantId = $enabled");
    } catch (e) {
      print("Error toggling mic for $participantId: $e");
    }
  }

  Future<void> toggleParticipantCamera(String participantId, bool enabled) async {
    if (_hub == null) return;

    try {

      if (participants.containsKey(participantId)) {
        participants[participantId]!.videoEnabled = enabled;
        notifyListeners();
      }

      await _hub!.invoke("ToggleCam", args: [
        eventId,
        participantId,
        enabled,
      ]);
      if (!enabled) {
        onParticipantCameraOff?.call(participantId);
      }

      print("🎥 Sent ToggleCam to $participantId = $enabled");
    } catch (e) {
      print("Error toggling camera for $participantId: $e");
    }
  }


  Future<void> leaveRoom() async {
    try {
      await _hub?.invoke("LeaveRoom", args: [eventId]);
      for (final pc in _peerConnections.values) {
        await pc.close();
      }
      _peerConnections.clear();
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
      participants.clear();
      await _hub?.stop();
      isConnected = false;
      notifyListeners();
    } catch (e) {
      //
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (_hub == null || !isConnected || eventId.isEmpty) return;

    final chatMessage = ChatMessage(sender: userName, message: message);

    try {
      await _hub!.invoke("SendChatMessage", args: [eventId, userName, message]);
    } catch (e) {}

    for (var listener in _chatListeners) {
      listener(chatMessage);
    }
    notifyListeners();
  }

  void addChatListener(ValueChanged<ChatMessage> listener) {
    _chatListeners.add(listener);
  }

  void removeChatListener(ValueChanged<ChatMessage> listener) {
    _chatListeners.remove(listener);
  }

  Future<void> endEvent() async {
    if (!isHost) return;
    try {
      await _hub?.invoke("EndRoom", args: [eventId]);
    } catch (e) {}
  }

  Future<void> muteAllParticipants() async {
    if (!isConnected || _hub == null) return;

    final participantIds = participants.keys.where((id) => id != myConnectionId).toList();

    for (final id in participantIds) {
      try {
        await _hub!.invoke("ToggleMic", args: [eventId, id, false]);
        if (participants.containsKey(id)) {
          participants[id]!.audioEnabled = false;
        }
      } catch (e) {}
    }
    notifyListeners();
    onAllMuted?.call();
  }

  Future<void> turnOffAllParticipantCameras() async {
    if (!isConnected || _hub == null) return;

    final participantIds = participants.keys.where((id) => id != myConnectionId).toList();

    for (final id in participantIds) {
      try {
        await _hub!.invoke("ToggleCam", args: [eventId, id, false]);
        if (participants.containsKey(id)) {
          participants[id]!.videoEnabled = false;
        }
      } catch (e) {}
    }
    notifyListeners();
    onAllCamsOff?.call();
  }
}

String _preferH264(String sdp) {
  final lines = sdp.split('\r\n');
  final vp8Index = lines.indexWhere((l) => l.contains('VP8/90000'));
  final h264Index = lines.indexWhere((l) => l.contains('H264/90000'));
  if (vp8Index > -1 && h264Index > -1) {
    final tmp = lines[vp8Index];
    lines[vp8Index] = lines[h264Index];
    lines[h264Index] = tmp;
  }
  return lines.join('\r\n');
}
