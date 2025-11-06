import 'package:flutter/material.dart';
import '../widgets/rating.dart';

class RatingScreen extends StatefulWidget {
  final String eventId;

  const RatingScreen({super.key, required this.eventId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text("Đánh giá sự kiện"),
          centerTitle: true,
        ),
        body: RatingWidget(eventId: widget.eventId),
      ),
    );
  }
}
