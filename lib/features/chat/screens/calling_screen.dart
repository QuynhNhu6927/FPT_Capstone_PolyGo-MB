import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../data/services/signalr/user_presence.dart';

class CallingScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  final bool isVideoCall;
  final bool isCaller;
  final bool initialIsConnecting;

  const CallingScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    this.isVideoCall = false,
    this.isCaller = true,
    this.initialIsConnecting = true,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  bool _isConnecting = true;
  bool isCallAccepted = false;
  bool micOn = true;
  bool camOn = true;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _isConnecting = widget.initialIsConnecting;
    _registerHubHandlers();

    if (widget.isCaller) _startCall();
  }

  @override
  void dispose() {
    _cleanupCall();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _registerHubHandlers() {
    final hub = UserPresenceManager().service;

    hub.registerCallHandlers(
      onCallAccepted: (receiverId) async {
        if (!mounted) return;
        if (receiverId != widget.receiverId) return;

        setState(() => isCallAccepted = true);
        await _initWebRTC(isCaller: true);
      },
      onCallDeclined: (receiverId) => _endCallWithUI(),
      onCallEnded: () => _endCallWithUI(),
      onReceiveOffer: (sdp) async {
        await _initWebRTC(isCaller: false);
        await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        await hub.sendAnswer(widget.receiverId, answer.sdp!);
      },
      onReceiveAnswer: (sdp) async {
        await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      },
      onReceiveIceCandidate: (candidateStr) async {
        final Map<String, dynamic> candidateMap = jsonDecode(candidateStr);
        final candidate = RTCIceCandidate(
          candidateMap['candidate'],
          candidateMap['sdpMid'],
          candidateMap['sdpMLineIndex'],
        );
        await _peerConnection?.addCandidate(candidate);
      },
    );
  }

  Future<void> _startCall() async {
    final hub = UserPresenceManager().service;
    if (!hub.isConnected) return;
    await hub.startCall(widget.receiverId, widget.isVideoCall);
  }

  Future<void> _initWebRTC({required bool isCaller}) async {
    // Nếu là video call, lấy cả audio + video
    Map<String, dynamic> mediaConstraints = {'audio': true, 'video': widget.isVideoCall};
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (widget.isVideoCall) _localRenderer.srcObject = _localStream;

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    // Add tracks
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Remote stream
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          if (widget.isVideoCall) _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        UserPresenceManager().service.sendIceCandidate(
          widget.receiverId,
          jsonEncode({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          }),
        );
      }
    };

    if (isCaller) {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      await UserPresenceManager().service.sendOffer(widget.receiverId, offer.sdp!);
    }
  }

  void _toggleMic() {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      final track = _localStream!.getAudioTracks()[0];
      track.enabled = !track.enabled;
      setState(() => micOn = track.enabled);
    }
  }

  void _toggleCamera() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final track = _localStream!.getVideoTracks()[0];
      track.enabled = !track.enabled;
      setState(() => camOn = track.enabled);
    }
  }

  void _endCallWithUI() async {
    await _cleanupCall();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuộc gọi đã kết thúc'), duration: Duration(seconds: 2)),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _cleanupCall() async {
    await UserPresenceManager().service.endCall();
    await _peerConnection?.close();
    _peerConnection = null;
    await _localStream?.dispose();
    await _remoteStream?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Call UI
          if (widget.isVideoCall)
            Positioned.fill(
              child: _remoteRenderer.srcObject != null
                  ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
                  : Container(color: Colors.black),
            ),

          // Call info (Voice Call hoặc Video Call trước khi remote connect)
          if (!widget.isVideoCall || _remoteRenderer.srcObject == null)
            _buildCallInfo(),

          // Local preview nhỏ (chỉ video call khi đã có stream)
          if (widget.isVideoCall && _localRenderer.srcObject != null)
            Positioned(
              top: 60,
              right: 20,
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),

          // Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _toggleMic,
                  icon: Icon(micOn ? Icons.mic : Icons.mic_off, color: Colors.white, size: 30),
                ),
                if (widget.isVideoCall) const SizedBox(width: 20),
                if (widget.isVideoCall)
                  IconButton(
                    onPressed: _toggleCamera,
                    icon: Icon(camOn ? Icons.videocam : Icons.videocam_off,
                        color: Colors.white, size: 30),
                  ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: _endCallWithUI,
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 30),
                ),
              ],
            ),
          ),

          // Connecting overlay
          if (_isConnecting && !isCallAccepted)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Calling...",
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallInfo() {
    final firstLetter = widget.receiverName.isNotEmpty ? widget.receiverName[0] : '?';
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.isVideoCall ? "Video Call" : "Voice Call",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              widget.receiverName,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 60,
              backgroundColor: widget.receiverAvatar.isEmpty ? Colors.grey : Colors.transparent,
              backgroundImage: widget.receiverAvatar.isNotEmpty
                  ? NetworkImage(widget.receiverAvatar)
                  : null,
              child: widget.receiverAvatar.isEmpty
                  ? Text(
                firstLetter,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              widget.receiverName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
