import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(loc.translate("conversation_list")),
          centerTitle: true,
        ),
      body: SafeArea(
        child: ConversationList(),
      ),
    );

  }
}
