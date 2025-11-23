import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/users_profile.dart';
import '../widgets/user_post_content.dart'; // import widget bài viết

class UserProfileScreen extends StatefulWidget {
  final String? userId;

  const UserProfileScreen({super.key, this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _hasError = false;
  bool _isRetrying = false;
  bool _loadPosts = false;
  final ScrollController _scrollController = ScrollController();

  void _onChildError() {
    if (!_hasError) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _onRetry() {
    setState(() {
      _hasError = false;
      _isRetrying = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isRetrying = false);
    });
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_loadPosts &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100) {
        // scroll gần cuối thì load post
        setState(() {
          _loadPosts = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      body: SafeArea(
        child: _hasError
            ? AppErrorState(onRetry: _onRetry)
            : SingleChildScrollView(
          controller: _scrollController, // gắn controller
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(
                    isDesktop
                        ? 32
                        : isTablet
                        ? 24
                        : 16,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 28,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              UserProfile(userId: widget.userId),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                thickness: 1,
              ),
              if (widget.userId != null && _loadPosts)
                UserPostContent(userId: widget.userId!),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
