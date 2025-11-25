import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

class FriendButton extends StatelessWidget {
  final String status;
  final AppLocalizations loc;
  final VoidCallback onSendRequest;
  final VoidCallback onCancelRequest;
  final VoidCallback onAcceptRequest;
  final VoidCallback onRejectRequest;
  final VoidCallback onUnfriend;

  const FriendButton({
    super.key,
    required this.status,
    required this.loc,
    required this.onSendRequest,
    required this.onCancelRequest,
    required this.onAcceptRequest,
    required this.onRejectRequest,
    required this.onUnfriend,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);

    switch (status) {
      case "None":
        return ElevatedButton.icon(
          onPressed: onSendRequest,
          icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 22),
          label: const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
          ),
        );

      case "Sent":
        return ElevatedButton.icon(
          onPressed: onCancelRequest,
          icon: const Icon(Icons.pending_outlined, color: Colors.white, size: 22),
          label: const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
          ),
        );

      case "Received":
        return ElevatedButton.icon(
          onPressed: () => _showFriendRequestDialog(context),
          icon: const Icon(Icons.pending_outlined, color: Colors.white, size: 22),
          label: const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
          ),
        );

      case "Friends":
        return ElevatedButton.icon(
          onPressed: () => _showUnfriendDialog(context),
          icon: const Icon(Icons.people_alt, color: Colors.white, size: 22),
          label: const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showFriendRequestDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate("Friend Request")),
        content: Text(loc.translate("Do you want to accept this friend request?")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRejectRequest();
            },
            child: Text(loc.translate("Reject")),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAcceptRequest();
            },
            child: Text(loc.translate("Accept")),
          ),
        ],
      ),
    );
  }

  void _showUnfriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate("Unfriend")),
        content: Text(loc.translate("Do you want to remove this friend?")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate("cancel")),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUnfriend();
            },
            child: Text(loc.translate("confirm")),
          ),
        ],
      ),
    );
  }
}
