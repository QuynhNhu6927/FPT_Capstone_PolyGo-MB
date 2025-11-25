import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/post/update_post_model.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/media_service.dart';
import '../../../../data/services/apis/post_service.dart';

class UpdatePostDialog extends StatefulWidget {
  final String userAvatar;
  final String postId;
  final VoidCallback onUpdated;

  const UpdatePostDialog({
    super.key,
    required this.userAvatar,
    required this.postId,
    required this.onUpdated,
  });

  @override
  State<UpdatePostDialog> createState() => _UpdatePostDialogState();
}

class _UpdatePostDialogState extends State<UpdatePostDialog> {
  final TextEditingController _controller = TextEditingController();

  List<String> _existingImages = [];
  List<XFile> _newImages = [];

  bool _loading = false;
  bool _isLoading = true;

  late final PostRepository _postRepo;

  String _originalText = '';
  List<String> _originalImages = [];

  bool get _hasChanges {
    final textChanged = _controller.text.trim() != _originalText.trim();
    final imagesChanged = _existingImages.length != _originalImages.length ||
        !_existingImages.every((e) => _originalImages.contains(e)) ||
        _newImages.isNotEmpty;
    return textChanged || imagesChanged;
  }

  @override
  void initState() {
    super.initState();
    _postRepo = PostRepository(PostService(ApiClient()));
    _controller.addListener(() => setState(() {}));
    _fetchPostDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetail() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Missing token");

      final res = await _postRepo.getPostDetail(
        token: token,
        postId: widget.postId,
      );

      if (!mounted) return;

      setState(() {
        _controller.text = res.data?.content ?? '';
        _existingImages = List.from(res.data?.imageUrls ?? []);
        _originalText = _controller.text;
        _originalImages = List.from(_existingImages);
      });
    } catch (e) {
      debugPrint("Load post failed $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null) {
      setState(() => _newImages.addAll(picked));
    }
  }

  Future<void> _handleUpdate() async {
    if (!_hasChanges) return;

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Missing token");

      List<String> uploadedUrls = [];

      if (_newImages.isNotEmpty) {
        final mediaRepo = MediaRepository(MediaService(ApiClient()));
        final uploadRes = await mediaRepo
            .uploadImages(token, _newImages.map((e) => File(e.path)).toList());

        uploadedUrls = uploadRes.data?.urls ?? [];
      }

      final finalImageUrls = [..._existingImages, ...uploadedUrls];

      // Gọi API update (void)
      final updateRequest = UpdatePostRequest(
        content: _controller.text.trim(),
        imageUrls: finalImageUrls,
      );

      await _postRepo.updatePost(
        token: token,
        postId: widget.postId,
        request: updateRequest,
      );

      if (mounted) {
        widget.onUpdated();
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Update failed: $e");
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("img_2_large"))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate("edit_post"),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: widget.userAvatar.isNotEmpty
                        ? NetworkImage(widget.userAvatar)
                        : null,
                    backgroundColor: Colors.grey,
                    child: widget.userAvatar.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Container()),
                  if (_hasChanges)
                    ElevatedButton(
                      onPressed: _loading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(loc.translate('save'), style: TextStyle(fontSize: 15)),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxHeight: 24.0 * 10),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: loc.translate('share_your_though'),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[700],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: isDark ? Colors.white70 : Colors.grey[800],
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: [
                    ..._existingImages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(url, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _existingImages.removeAt(idx)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    ..._newImages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;

                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(img.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _newImages.removeAt(idx)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

