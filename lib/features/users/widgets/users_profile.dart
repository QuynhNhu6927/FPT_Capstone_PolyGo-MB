import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/user_service.dart';
import '../../../../data/models/user/user_by_id_response.dart';
import '../../../../core/api/api_client.dart';

class UserProfile extends StatefulWidget {
  final String? userId;

  const UserProfile({super.key, this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _loading = true;
  bool _hasError = false;
  UserByIdResponse? user;

  late final UserRepository _userRepo;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(UserService(ApiClient()));
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || widget.userId == null) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
        return;
      }

      final result = await _userRepo.getUserById(token, widget.userId!);
      if (mounted) {
        setState(() {
          user = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.6
        : 900.0;

    if (_loading) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: containerWidth,
          padding: const EdgeInsets.all(24),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_hasError || user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text("Failed to load user profile"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _hasError = false;
                });
                _loadUser();
              },
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    // ✅ Extract data safely with null checks
    final avatarUrl = user!.avatarUrl;
    final name = user!.name ?? "Unnamed";
    final meritLevel = user!.meritLevel;
    final experiencePoints = user!.experiencePoints;
    final introduction = user!.introduction;
    final nativeLangs = (user!.speakingLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final learningLangs = (user!.learningLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final interests = (user!.interests ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final bool hasNoData =
        nativeLangs.isEmpty && learningLangs.isEmpty && interests.isEmpty && (introduction == null || introduction.isEmpty);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                : [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
            // ✅ Header: Avatar + Name (handle null avatar safely)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (avatarUrl != null && avatarUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(avatarUrl),
                  )
                else
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
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
                      const SizedBox(height: 4),
                      if (meritLevel != null || experiencePoints != null)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            if (meritLevel != null) ...[
                              const Icon(Icons.star,
                                  color: Colors.blueAccent, size: 18),
                              Text(meritLevel, style: t.bodyMedium),
                            ],
                            if (meritLevel != null && experiencePoints != null)
                              const Text("•"),
                            if (experiencePoints != null)
                              Text("$experiencePoints EXP", style: t.bodyMedium),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Introduction (only show if not null & not empty)
            if (introduction != null && introduction.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Introduction",
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    introduction,
                    style: t.bodyMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // ✅ Info Sections
            if (!hasNoData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nativeLangs.isNotEmpty) ...[
                    Text(
                      "Native Languages",
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTagList(nativeLangs, Colors.green[100]!),
                    const SizedBox(height: 16),
                  ],
                  if (learningLangs.isNotEmpty) ...[
                    Text(
                      "Learning",
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTagList(learningLangs, Colors.blue[100]!),
                    const SizedBox(height: 20),
                  ],
                  if (interests.isNotEmpty) ...[
                    Text(
                      "Interests",
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTagList(interests, const Color(0xFFF3F4F6)),
                  ],
                ],
              )
            else
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Text(
                  "No information yet.",
                  style: t.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTagList(List<String> items, Color color) {
    return SizedBox(
      height: 25,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _buildTag(items[i], color: color),
      ),
    );
  }

  Widget _buildTag(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black),
      ),
    );
  }
}
