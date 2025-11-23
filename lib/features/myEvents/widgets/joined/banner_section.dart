import 'package:flutter/material.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../../core/utils/responsive.dart';

class BannerSection extends StatelessWidget {
  final JoinedEventModel event;

  const BannerSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: event.bannerUrl.isNotEmpty
          ? Image.network(
        event.bannerUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.event_note_rounded,
              size: 64,
              color: Colors.white70,
            ),
          ),
        ),
      )
          : Container(
        color: Colors.grey[400],
        child: const Center(
          child: Icon(
            Icons.event_note_rounded,
            size: 64,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
