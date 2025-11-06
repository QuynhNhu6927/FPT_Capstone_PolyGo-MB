import 'package:flutter/material.dart';
import '../widgets/rates.dart';
import '../widgets/rating.dart';

class RatesScreen extends StatefulWidget {
  final String eventId;

  const RatesScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
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
        body: Rates(eventId: widget.eventId),
      ),
    );

  }
}
