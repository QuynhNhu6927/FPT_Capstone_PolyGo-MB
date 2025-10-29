import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';

class Notification extends StatelessWidget {
  const Notification({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;

    final notifications = [
      {
        "type": "user",
        "avatar":
        "https://i.pravatar.cc/150?img=3",
        "content": "Nguyễn Minh vừa tặng bạn một món quà đặc biệt!",
        "date": "19/10/2025, 08:30",
      },
      {
        "type": "system",
        "avatar": 'lib/assets/Primary2.png',
        "content": "Hệ thống sẽ bảo trì lúc 23:00 tối nay.",
        "date": "19/10/2025, 07:00",
      },
      {
        "type": "user",
        "avatar":
        "https://i.pravatar.cc/150?img=5",
        "content": "Trần Anh đã chấp nhận yêu cầu kết bạn của bạn.",
        "date": "18/10/2025, 21:15",
      },
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isUser = item["type"] == "user";
          final avatar = item["avatar"];
          final content = item["content"] as String;
          final date = item["date"] as String;

          String? userName;
          String message = content;
          final namePattern = RegExp(r"^([A-ZĐÂĂÊÔƠƯ][^\s]+(\s[A-ZĐÂĂÊÔƠƯa-zđâăêôơư]+){0,2})");
          final match = namePattern.firstMatch(content);
          if (match != null && isUser) {
            userName = match.group(1);
            message = content.replaceFirst(userName!, "").trim();
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    backgroundImage: isUser
                        ? NetworkImage(avatar!)
                        : AssetImage(avatar!) as ImageProvider,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: t.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            children: [
                              if (userName != null)
                                TextSpan(
                                  text: "$userName ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              TextSpan(text: message),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          date,
                          style: t.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms, delay: (index * 80).ms);
        },
      ),
    );
  }
}
