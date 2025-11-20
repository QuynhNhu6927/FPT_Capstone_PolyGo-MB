import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharedContainer extends StatelessWidget {
  final Widget child;

  const SharedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: Theme.of(context).cardColor.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: child,
    );
  }
}
