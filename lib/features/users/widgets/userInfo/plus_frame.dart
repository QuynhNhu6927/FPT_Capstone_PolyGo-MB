import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShinyAvatar extends StatefulWidget {
  final String? avatarUrl;

  const ShinyAvatar({
    super.key,
    required this.avatarUrl,
  });

  @override
  State<ShinyAvatar> createState() => _ShinyAvatarState();
}

class _ShinyAvatarState extends State<ShinyAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.avatarUrl;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [
                Color(0xFFFFD700),
                Color(0xFFFFA500),
                Color(0xFFFFFF00),
                Color(0xFFFFD700),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            backgroundColor: Colors.grey[300],
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 36)
                : null,
          ),
        );
      },
    );
  }
}
