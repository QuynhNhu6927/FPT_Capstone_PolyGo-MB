import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/media_service.dart';
import '../../../../data/services/apis/post_service.dart';

class CreatePostDialog extends StatefulWidget {
  final String? userAvatar;
  final VoidCallback onPosted;

  const CreatePostDialog({
    super.key,
    required this.userAvatar,
    required this.onPosted,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _controller = TextEditingController();
  List<XFile> _images = [];
  bool _loading = false;

  bool get _canPost =>
      _controller.text.trim().isNotEmpty || _images.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        backgroundColor: theme.scaffoldBackgroundColor,
        systemOverlayStyle:
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate("create_post"),
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
              // Hàng đầu: Avatar + nút Đăng
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.userAvatar != null
                        ? NetworkImage(widget.userAvatar!)
                        : null,
                    child: widget.userAvatar == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Container()),
                  if (_canPost)
                    ElevatedButton(
                      onPressed: _loading ? null : _handlePost,
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
                          : Text(loc.translate(
                        "post_post"),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // TextField nhập nội dung
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  maxHeight: 10 * 24.0, // max 10 dòng
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: loc.translate("share_your_though"),
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.grey[700],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nút thêm ảnh phía dưới, bên trái
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey[800],
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hiển thị ảnh đã chọn
              Expanded(
                child: ListView(
                  children: [
                    ..._images.asMap().entries.map((entry) {
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
                                  width: double.infinity,
                                  height: 200,
                                )

                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(idx)),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? picked = await picker.pickMultiImage(
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 70,
    );

    if (picked != null) {
      List<XFile> compressedImages = [];

      for (var img in picked) {
        // Nén thêm bằng flutter_image_compress
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          img.path,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
        );

        if (compressedBytes != null) {
          // Lưu ảnh đã nén tạm vào File
          final tempFile = File('${Directory.systemTemp.path}/${img.name}');
          await tempFile.writeAsBytes(compressedBytes);
          compressedImages.add(XFile(tempFile.path));
        } else {
          compressedImages.add(img);
        }
      }

      setState(() {
        _images.addAll(compressedImages);
      });
    }
  }


  Future<void> _handlePost() async {
    // Kiểm tra nếu nội dung trống
    if (_controller.text.trim().isEmpty) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("cant_empty_caption"))),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token missing");

      List<String> uploadedUrls = [];

      if (_images.isNotEmpty) {
        final mediaRepo = MediaRepository(MediaService(ApiClient()));
        final uploadRes = await mediaRepo
            .uploadImages(token, _images.map((e) => File(e.path)).toList());

        uploadedUrls = uploadRes.data?.urls ?? [];
      }

      final postRepo = PostRepository(PostService(ApiClient()));
      await postRepo.createPost(
        token: token,
        content: _controller.text.trim(),
        imageUrls: uploadedUrls,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
      widget.onPosted();
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.translate("img_2_large"))));
    }

    if (mounted) setState(() => _loading = false);
  }

}
