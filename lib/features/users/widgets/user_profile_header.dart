import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/users/widgets/plus_frame.dart';
import 'package:polygo_mobile/features/users/widgets/sent_gifts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/friend_repository.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/services/apis/conversation_service.dart';
import '../../../data/services/apis/friend_service.dart';
import '../../../../core/api/api_client.dart';
import '../../../routes/app_routes.dart';
import '../../shared/about_merit.dart';
import '../../shared/about_plus.dart';
import '../../shared/about_streak.dart';
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
  bool _isChatLoading = false;

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
    final int? merit = widget.user.merit;
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
              CircleAvatar(
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
            const SizedBox(height: 6),
          ],

          // ---------- Tags Row ----------
          if ((widget.user != null && experiencePoints != null) ||
              (widget.user.planType == 'Plus')
              // (widget.user.streakDays != null && widget.user.streakDays! > 0)
          ) ...[
            SizedBox(height: sh(context, 12)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // PlanType tag
                  if (widget.user.planType == 'Plus')
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AboutPlusDialog(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(sw(context, 8)),
                        margin: EdgeInsets.only(right: sw(context, 8)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orangeAccent,
                              Colors.yellow,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(sw(context, 16)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_sharp,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: sw(context, 4)),
                            Text(
                              "Plus Member",
                              style: t.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Merit tag
                  if (merit != null)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AboutMeritDialog(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw(context, 12),
                          vertical: sh(context, 6),
                        ),
                        margin: EdgeInsets.only(right: sw(context, 8)),
                        decoration: BoxDecoration(
                          gradient: merit >= 80
                              ? const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // xanh lá đậm -> xanh lá nhạt
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : merit >= 40
                              ? const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFEB3B)], // vàng đậm -> vàng nhạt
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : const LinearGradient(
                            colors: [Color(0xFFF44336), Color(0xFFE57373)], // đỏ đậm -> đỏ nhạt
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(sw(context, 16)),
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.verified_user, size: 16, color: Colors.white),
                            SizedBox(width: sw(context, 4)),
                            Text(
                              "$merit",
                              style: t.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SentGiftsDialog(receiverId: widget.user.id),
                    );
                  },
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

              // Chat button
              if (_friendStatus == "Friends") ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _isChatLoading = true);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token') ?? '';
                        final repo = ConversationRepository(ConversationService(ApiClient()));

                        final conversation = await repo.getConversationByUser(
                          token: token,
                          userId: widget.user.id,
                        );
                        if (!mounted) return;

                        if (conversation != null) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.conversation,
                            arguments: {
                              'conversationId': conversation.id,
                              'userName': conversation.user.name,
                              'avatarHeader': conversation.user.avatarUrl ?? '',
                              'lastActiveAt': conversation.user.lastActiveAt ?? '',
                              'isOnline': conversation.user.isOnline,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Không thể mở đoạn chat.")),
                          );
                        }
                      } catch (e, s) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: $e")),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
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
