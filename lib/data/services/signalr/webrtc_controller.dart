import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../repositories/auth_repository.dart';
import '../auth_service.dart';

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
      localStream?.getAudioTracks().forEach((t) =>
      t.enabled = localAudioEnabled);
      localStream?.getVideoTracks().forEach((t) =>
      t.enabled = localVideoEnabled);
      notifyListeners();
    } catch (e) {
      //
    }
  }

  // --- Create PeerConnection ---
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
              () =>
              Participant(
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
    print("[SignalR] 🔌 Connecting to $hubUrl ...");
    _hub = HubConnectionBuilder().withUrl(hubUrl).withAutomaticReconnect().build();

    _hub!.onclose((error) {
      print("[SignalR] ❌ Disconnected: $error");
    });
    _hub!.onreconnecting((error) {
      print("[SignalR] ⚠️ Reconnecting... cause=$error");
    });
    _hub!.onreconnected((connectionId) {
      print("[SignalR] ✅ Reconnected with new connId=$connectionId");
    });

    _hub!.on('SetRole', (args) {
      print("[SignalR] 📩 SetRole event: $args");
      myConnectionId = args?[1];
      hostId = args?[2];

      if (hostId != null && participants.containsKey(hostId)) {
        participants[hostId!]!.role = "host";
      }
      notifyListeners();
    });

    _hub!.on('UserJoined', (args) async {
      print("[SignalR] 👋 UserJoined: $args");
      final name = args?[0] ?? "Unknown";
      final connId = args?[2];

      participants[connId] = Participant(
        id: connId,
        name: name,
        role: connId == hostId ? "host" : "attendee",
      );
      notifyListeners();

      if (connId != myConnectionId) {
        print("[SignalR] 🔄 Creating offer to $connId ...");
        final pc = await createPeer(connId);
        final offer = await pc.createOffer();
        await pc.setLocalDescription(RTCSessionDescription(offer.sdp!, 'offer'));
        await _hub?.invoke("SendOffer", args: [eventId, connId, offer.sdp]);
        print("[SignalR] 📤 Sent offer to $connId");
      }
    });

    _hub!.on('ReceiveMediaState', (args) {
      print("[SignalR] 🎧 ReceiveMediaState: $args");
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
        notifyListeners();
      }
    });

    _hub!.on('UserLeft', (args) {
      print("[SignalR] 👋 UserLeft: $args");
      final connId = args?[0];
      participants.remove(connId);
      notifyListeners();
    });

    _hub!.on('ReceiveChatMessage', (args) {
      print("[SignalR] 💬 ReceiveChatMessage: $args");
      final sender = args?[0] ?? "Unknown";
      final message = args?[1] ?? "";
      final chatMessage = ChatMessage(sender: sender, message: message);
      chatMessages.add(chatMessage);
      for (var listener in _chatListeners) {
        listener(chatMessage);
      }
      notifyListeners();
    });

    _hub!.on('ToggleMicCommand', (args) {
      print("[SignalR] 🎤 Received ToggleMicCommand: $args");
      final enabled = args?[0] ?? true;
      localStream?.getAudioTracks().forEach((t) {
        t.enabled = enabled;
        print("[SignalR] 🎚 Audio track ${t.id} -> ${enabled ? 'ENABLED' : 'DISABLED'}");
      });
      localAudioEnabled = enabled;
      notifyListeners();
    });

    _hub!.on('ToggleCamCommand', (args) {
      print("[SignalR] 🎥 Received ToggleCamCommand: $args");
      final enabled = args?[0] ?? true;
      localStream?.getVideoTracks().forEach((t) {
        t.enabled = enabled;
        print("[SignalR] 🎚 Video track ${t.id} -> ${enabled ? 'ENABLED' : 'DISABLED'}");
      });
      localVideoEnabled = enabled;
      notifyListeners();
    });

    _hub!.on('ReceiveOffer', (args) async {
      print("[SignalR] 📩 ReceiveOffer: $args");
      final fromConnId = args?[0];
      final sdp = args?[1];

      final pc = await createPeer(fromConnId);
      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _hub?.invoke("SendAnswer", args: [eventId, fromConnId, answer.sdp]);
      print("[SignalR] 📤 Sent Answer to $fromConnId");
    });

    _hub!.on('ReceiveAnswer', (args) async {
      print("[SignalR] 📩 ReceiveAnswer: $args");
      final fromConnId = args?[0];
      final sdp = args?[1];

      final pc = _peerConnections[fromConnId];
      if (pc == null) {
        print("[SignalR] ⚠️ No peer for $fromConnId");
        return;
      }

      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
    });

    _hub!.on('RoomEnded', (args) async {
      print("[SignalR] 🛑 RoomEnded event received");
      await leaveRoom();
      if (onRoomEnded != null) {
        onRoomEnded!();
      }
    });

    _hub!.on('ReceiveIceCandidate', (args) async {
      print("[SignalR] 🧊 ReceiveIceCandidate: $args");
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

    await _hub!.start();
    isConnected = true;
    print("[SignalR] ✅ Connected successfully!");
  }

  Future<void> joinRoom({required bool isHost}) async {
    if (_hub == null || !isConnected) {
      print("[SignalR] ❌ joinRoom() failed: hub not connected");
      return;
    }

    String actualName = userName;

    print("[SignalR] 🚪 Joining room $eventId as $actualName with isHost=$isHost...");
    await _hub!.invoke("JoinRoom", args: [eventId, actualName, isHost]);

    try {
      final result = await _hub!.invoke("GetParticipants", args: [eventId]);
      print("[SignalR] 👥 GetParticipants result: $result");
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
      print("[SignalR] ⚠️ GetParticipants failed: $e");
    }
  }

  // --- Start Call ---
  Future<void> startCall() async {
    if (participants.isEmpty) {
      return;
    }

    for (final remoteId in participants.keys) {
      if (remoteId == myConnectionId) continue;

      final pc = await createPeer(remoteId);

      final offer = await pc.createOffer();
      String modifiedSdp = _preferH264(offer.sdp!);
      await pc.setLocalDescription(RTCSessionDescription(modifiedSdp, 'offer'));
      await _hub?.invoke("SendOffer", args: [eventId, remoteId, modifiedSdp]);
    }
  }

  // --- Toggle Audio / Video với broadcast ---
  Future<void> toggleAudio() async {
    final audioTrack = localStream
        ?.getAudioTracks()
        .firstOrNull;
    if (audioTrack == null) return;

    audioTrack.enabled = !audioTrack.enabled;
    localAudioEnabled = audioTrack.enabled;

    // Gửi trạng thái cho server
    if (_hub != null && isConnected) {
      try {
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "audio",
          localAudioEnabled,
        ]);
      } catch (e) {}
    }

    notifyListeners();
  }

  Future<void> toggleVideo() async {
    final videoTrack = localStream
        ?.getVideoTracks()
        .firstOrNull;
    if (videoTrack == null) return;

    videoTrack.enabled = !videoTrack.enabled;
    localVideoEnabled = videoTrack.enabled;

    // Gửi trạng thái cho server
    if (_hub != null && isConnected) {
      try {
        await _hub!.invoke("BroadcastMediaState", args: [
          eventId,
          myConnectionId,
          "video",
          localVideoEnabled,
        ]);
      } catch (e) {}
    }

    notifyListeners();
  }

  // --- Leave Room ---
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
    } catch (e) {
      //
    }
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
      } catch (e) {
        if (kDebugMode) {
          print("[SignalR] ✗ Failed to mute $id: $e");
        }
      }
    }

    notifyListeners();
  }

  Future<void> turnOffAllParticipantCameras() async {
    if (!isConnected || _hub == null) return;

    final participantIds = participants.keys.where((id) => id != myConnectionId).toList();

    for (final id in participantIds) {
      try {
        await _hub!.invoke("ToggleCam", args: [eventId, id, false]);

        // **Cập nhật trạng thái ngay lập tức**
        if (participants.containsKey(id)) {
          participants[id]!.videoEnabled = false;
        }
      } catch (e) {
        if (kDebugMode) {
          print("[SignalR] ✗ Failed to turn off camera for $id: $e");
        }
      }
    }

    notifyListeners();
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