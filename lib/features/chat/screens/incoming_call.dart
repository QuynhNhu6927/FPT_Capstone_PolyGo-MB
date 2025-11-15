import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    this.isVideoCall = false,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = callerName.isNotEmpty ? callerName[0] : '?';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            isVideoCall ? "Video Call From" : "Voice Call From",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            callerName,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 50),
          CircleAvatar(
            radius: 60,
            backgroundColor: callerAvatar.isEmpty ? Colors.grey : Colors.transparent,
            backgroundImage: callerAvatar.isNotEmpty ? NetworkImage(callerAvatar) : null,
            child: callerAvatar.isEmpty
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
            callerName,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Từ chối
              IconButton(
                onPressed: onDecline,
                icon: const Icon(Icons.call_end, color: Colors.red, size: 40),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.call, color: Colors.green, size: 40),
              ),
            ],
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

