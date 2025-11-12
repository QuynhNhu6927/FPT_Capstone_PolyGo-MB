import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/friends/friend_model.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/services/apis/friend_service.dart';
import '../../profile/widgets/shiny_avatar.dart';
import '../../shared/app_error_state.dart';

class Requests extends StatefulWidget {
  final bool isRetrying;
  final VoidCallback? onError;

  const Requests({super.key, this.isRetrying = false, this.onError});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  late final FriendRepository _repo;
  bool _loading = true;
  bool _hasError = false;
  List<FriendModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _repo = FriendRepository(FriendService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRequests();
  }

  @override
  void didUpdateWidget(covariant Requests oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadRequests();
    }
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
        widget.onError?.call();
        return;
      }

      final res = await _repo.getAllRequest(token);
      if (!mounted) return;

      setState(() {
        _requests = res;
        _loading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
      widget.onError?.call();
    }
  }

  Future<void> _acceptRequest(FriendModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final success = await _repo.acceptFriendRequest(token, user.id);
      if (success) {
        setState(() {
          _requests.removeWhere((u) => u.id == user.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chấp nhận yêu cầu kết bạn'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chấp nhận yêu cầu')),
      );
    }
  }

  Future<void> _rejectRequest(FriendModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final success = await _repo.rejectFriendRequest(token, user.id);
      if (success) {
        setState(() {
          _requests.removeWhere((u) => u.id == user.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối yêu cầu kết bạn'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể từ chối yêu cầu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadRequests),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          "Không có yêu cầu kết bạn",
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _requests[index];
          final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

          Widget avatar = hasAvatar
              ? CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(user.avatarUrl!),
            backgroundColor: Colors.grey[300],
          )
              : CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white, size: 25),
          );

          if (user.planType == "Plus") {
            avatar = ShinyAvatar(avatarUrl: user.avatarUrl);
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name ?? "Unknown",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptRequest(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rejectRequest(user),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
