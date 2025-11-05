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
    switch (status) {
      case "Sent":
        return ElevatedButton.icon(
          onPressed: onCancelRequest,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.close, color: Colors.white, size: 20),
              SizedBox(width: 4),
              Icon(Icons.mail_outline, color: Colors.white, size: 20),
            ],
          ),
          label: Text(
            loc.translate(""),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );

      case "Received":
        return ElevatedButton.icon(
          onPressed: () => _showFriendRequestDialog(context),
          icon: const Icon(Icons.mail_outline, color: Colors.black87),
          label: Text(
            loc.translate(""),
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );

      case "Friends":
        return ElevatedButton.icon(
          onPressed: () => _showUnfriendDialog(context),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.black87, size: 20),
              SizedBox(width: 4),
              Icon(Icons.person, color: Colors.black87, size: 20),
            ],
          ),
          label: Text(
            loc.translate(""),
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );

      default:
        return OutlinedButton.icon(
          onPressed: onSendRequest,
          icon: const Icon(Icons.person_add, color: Color(0xFF2563EB)),
          label: Text(
            loc.translate(""),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2563EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );
    }
  }

  void _showFriendRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Friend Request"),
        content: const Text("Do you want to accept this friend request?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRejectRequest();
            },
            child: const Text("Reject"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAcceptRequest();
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void _showUnfriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unfriend"),
        content: const Text("Do you want to remove this friend?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUnfriend();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
