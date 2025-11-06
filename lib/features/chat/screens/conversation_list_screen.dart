import 'package:flutter/material.dart';
import '../widgets/conversation_list.dart';

class ConversationListScreen extends StatefulWidget {

  const ConversationListScreen({
    super.key,
  });

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
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
          title: const Text("Cuộc hội thoại"),
          centerTitle: true,
        ),
        body: ConversationList(),
      ),
    );

  }
}
