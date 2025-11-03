import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

class Participant {
  final String id;
  final String name;
  final String role;
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

class WebRTCController extends ChangeNotifier {
  final Map<String, RTCPeerConnection> _peerConnections = {};

  final String eventId;
  final String userName;
  final bool isHost;

  HubConnection? _hub;
  bool isConnected = false;
  String? myConnectionId;
  String? hostId;

  Map<String, Participant> participants = {};
  MediaStream? localStream;
  bool localAudioEnabled = true;
  bool localVideoEnabled = true;

  WebRTCController({
    required this.eventId,
    required this.userName,
    required this.isHost,
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

      notifyListeners();
    } catch (e) {
    }
  }

  // --- Create PeerConnection ---
  Future<RTCPeerConnection> createPeer(String remoteId) async {
    if (_peerConnections.containsKey(remoteId)) {
      print("[PC] Reusing peer connection for $remoteId");
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
        print("[ICE] Sent candidate to $remoteId");
      } catch (e) {
        print("[ICE] Failed to send candidate: $e");
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
        print("[Track] Got remote stream for $remoteId (${stream.id})");
        notifyListeners();
      }
    };

    _peerConnections[remoteId] = pc;
    return pc;
  }

  Future<void> initSignalR() async {
    final hubUrl = "http://160.25.81.144:8080/eventRoomHub";
    _hub = HubConnectionBuilder().withUrl(hubUrl).withAutomaticReconnect().build();

    _hub!.on('SetRole', (args) {
      final role = args?[0];
      myConnectionId = args?[1];
      hostId = args?[2];
      print("[SignalR] SetRole: $role | id=$myConnectionId | hostId=$hostId");
      notifyListeners();
    });

    _hub!.on('UserJoined', (args) {
      final name = args?[0] ?? "Unknown";
      final role = args?[1] ?? "attendee";
      final connId = args?[2];
      participants[connId] = Participant(
        id: connId,
        name: name,
        role: role == "host" ? "host" : "attendee",
      );
      print("[SignalR] UserJoined: $name ($connId)");
      notifyListeners();
    });

    _hub!.on('UserLeft', (args) {
      final connId = args?[0];
      participants.remove(connId);
      print("[SignalR] UserLeft: $connId");
      notifyListeners();
    });

    _hub!.on('ReceiveChatMessage', (args) {
      final sender = args?[0];
      final message = args?[1];
      print("[Chat] $sender: $message");
    });

    _hub!.on('ReceiveOffer', (args) async {
      final fromConnId = args?[0];
      final sdp = args?[1];
      print("[SignalR] ReceiveOffer from $fromConnId");

      final pc = await createPeer(fromConnId);
      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _hub?.invoke("SendAnswer", args: [eventId, fromConnId, answer.sdp]);
      print("[SignalR] Sent Answer to $fromConnId");
    });

    _hub!.on('ReceiveAnswer', (args) async {
      final fromConnId = args?[0];
      final sdp = args?[1];
      print("[SignalR] ReceiveAnswer from $fromConnId");

      final pc = _peerConnections[fromConnId];
      if (pc == null) {
        print("[PC] No peer connection for $fromConnId");
        return;
      }

      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      print("[PC] Remote description set for $fromConnId");
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
      print("[ICE] Candidate added for $fromConnId");
    });

    await _hub!.start();
    isConnected = true;
  }

  Future<void> joinRoom() async {
    if (_hub == null || !isConnected) {
      return;
    }

    await _hub!.invoke("JoinRoom", args: [eventId, userName]);
    print("[SignalR] Joined room: $eventId as $userName");

    try {
      final result = await _hub!.invoke("GetParticipants", args: [eventId]);
      if (result is Map) {
        result.forEach((id, name) {
          if (id != myConnectionId) {
            participants[id] = Participant(
              id: id,
              name: name,
              role: "attendee",
            );
          }
        });
        print("[SignalR] Loaded ${participants.length} participants");
      }
      notifyListeners();
    } catch (e) {
      print("[SignalR] GetParticipants failed: $e");
    }
  }

  // --- Start Call ---
  Future<void> startCall() async {
    if (participants.isEmpty) {
      print("[WebRTC] No remote participants to call");
      return;
    }

    for (final remoteId in participants.keys) {
      if (remoteId == myConnectionId) continue;

      final pc = await createPeer(remoteId);

      final offer = await pc.createOffer();
      String modifiedSdp = _preferH264(offer.sdp!);
      await pc.setLocalDescription(RTCSessionDescription(modifiedSdp, 'offer'));
      await _hub?.invoke("SendOffer", args: [eventId, remoteId, modifiedSdp]);
      print("[SDP Offer Codec Check] ${offer.sdp}");
      print("[WebRTC] Sent offer to $remoteId");
    }
  }

  // --- Toggle Audio / Video ---
  Future<void> toggleAudio() async {
    final audioTrack = localStream?.getAudioTracks().firstOrNull;
    if (audioTrack == null) return;
    audioTrack.enabled = !audioTrack.enabled;
    localAudioEnabled = audioTrack.enabled;
    print("[Media] Audio ${audioTrack.enabled ? 'on' : 'off'}");
    notifyListeners();
  }

  Future<void> toggleVideo() async {
    final videoTrack = localStream?.getVideoTracks().firstOrNull;
    if (videoTrack == null) return;
    videoTrack.enabled = !videoTrack.enabled;
    localVideoEnabled = videoTrack.enabled;
    print("[Media] Video ${videoTrack.enabled ? 'on' : 'off'}");
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
      print("[WebRTC] Left room and cleaned up ✅");
      notifyListeners();
    } catch (e) {
      print("[WebRTC] Leave room error: $e");
    }
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