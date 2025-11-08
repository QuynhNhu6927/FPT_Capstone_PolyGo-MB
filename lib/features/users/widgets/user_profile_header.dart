import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/users/widgets/plus_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/friend_repository.dart';
import '../../../../data/services/friend_service.dart';
import '../../../../core/api/api_client.dart';
import 'friend_button.dart';

class UserProfileHeader extends StatefulWidget {
  final dynamic user;
  final AppLocalizations loc;

  const UserProfileHeader({
    super.key,
    required this.user,
    required this.loc,
  });

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  late String _friendStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _friendStatus = widget.user.friendStatus ?? "None";
  }

  // ------------------- Friend handlers giữ nguyên -------------------

  Future<void> _handleSendFriendRequest() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final repo = FriendRepository(FriendService(ApiClient()));

      await repo.sendFriendRequest(token, widget.user.id);
      setState(() => _friendStatus = "Sent");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelFriendRequest() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final repo = FriendRepository(FriendService(ApiClient()));

      await repo.cancelFriendRequest(token, widget.user.id);
      setState(() => _friendStatus = "None");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request cancelled!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAcceptFriendRequest() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final repo = FriendRepository(FriendService(ApiClient()));

      final success = await repo.acceptFriendRequest(token, widget.user.id);
      if (success) {
        setState(() => _friendStatus = "Friends");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request accepted!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRejectFriendRequest() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final repo = FriendRepository(FriendService(ApiClient()));

      final success = await repo.rejectFriendRequest(token, widget.user.id);
      if (success) {
        setState(() => _friendStatus = "None");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request rejected!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnfriend() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final repo = FriendRepository(FriendService(ApiClient()));

      final success = await repo.unfriend(token, widget.user.id);
      if (success) {
        setState(() => _friendStatus = "None");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfriended successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------- Build UI -------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final avatarUrl = widget.user.avatarUrl;
    final name = widget.user.name ?? "Unnamed";
    final experiencePoints = widget.user.experiencePoints;
    final introduction = widget.user.introduction ?? "";

    const blue = Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Avatar + Name ----------------
          Row(
            children: [
              widget.user.planType == "Plus"
                  ? ShinyAvatar(avatarUrl: avatarUrl)
                  : CircleAvatar(
                radius: 36,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                backgroundColor: Colors.grey[300],
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 36)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (experiencePoints != null)
                      Text("$experiencePoints EXP", style: t.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---------------- Introduction ----------------
          if (introduction.isNotEmpty) ...[
            Text(
              widget.loc.translate("introduction"),
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              introduction,
              style: t.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 20),
          ],

          // ---------------- Buttons ----------------
          Row(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FriendButton(
                  status: _friendStatus,
                  loc: widget.loc,
                  onSendRequest: _handleSendFriendRequest,
                  onCancelRequest: _handleCancelFriendRequest,
                  onAcceptRequest: _handleAcceptFriendRequest,
                  onRejectRequest: _handleRejectFriendRequest,
                  onUnfriend: _handleUnfriend,
                ),
              ),
              const SizedBox(width: 12),

              // Gift button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              // Chat button — chỉ hiện nếu là bạn bè
              if (_friendStatus == "Friends") ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: mở màn hình chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
