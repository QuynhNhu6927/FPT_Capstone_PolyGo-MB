import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/wordsets/start_wordset_response.dart';

class PlayInfoRowWidget extends StatefulWidget {
  final WordSetData startData;
  final ValueNotifier<int> progressNotifier;
  final ValueNotifier<int> mistakesNotifier;
  final ValueNotifier<int> hintsNotifier;
  final ValueNotifier<bool> isCompletedNotifier;

  const PlayInfoRowWidget({
    super.key,
    required this.startData,
    required this.progressNotifier,
    required this.mistakesNotifier,
    required this.hintsNotifier,
    required this.isCompletedNotifier,
  });

  @override
  State<PlayInfoRowWidget> createState() => _PlayInfoRowWidgetState();
}

class _PlayInfoRowWidgetState extends State<PlayInfoRowWidget> {
  int elapsedSeconds = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });

    widget.isCompletedNotifier.addListener(() {
      if (widget.isCompletedNotifier.value) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _infoCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final colorPrimary = const Color(0xFF2563EB);
    final cardBg = isDark
        ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(sw(context, 12)),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: colorPrimary),
                const SizedBox(width: 4),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sw(context, 16)),
        constraints: const BoxConstraints(maxWidth: 700),
        child: Row(
          children: [
            _infoCard(context, "Time", _formatTime(elapsedSeconds), Icons.timer),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: widget.progressNotifier,
              builder: (_, progress, __) =>
                  _infoCard(context, "Progress", "$progress/${widget.startData.totalWords}", Icons.track_changes),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: widget.mistakesNotifier,
              builder: (_, mistakes, __) => _infoCard(context, "Mistakes", "$mistakes", Icons.close),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: widget.hintsNotifier,
              builder: (_, hints, __) => _infoCard(context, "Hints", "$hints", Icons.lightbulb_outline),
            ),
          ],
        ),
      ),
    );
  }
}
