import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/chat/conversation_message_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_signalr_service.dart';
import '../../../data/services/conversation_service.dart';
import '../../../data/services/media_service.dart';
import 'chat_bubble.dart';

class Conversation extends StatefulWidget {
  final String conversationId;
  final String userName;

  const Conversation({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  bool _isUploadingImages = false;

  late ChatSignalrService _chatSignalrService;
  String? _showTimeMessageId;
  List<ConversationMessage> _messages = [];
  bool _isLoading = false;
  int _pageNumber = 1;
  final int _pageSize = 20;
  bool _hasNextPage = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  String? _currentUserId;
  bool _loadingUser = false;
  bool _userError = false;

  String _myUserId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser().then((_) {
      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        _myUserId = _currentUserId!;
        _initSignalR();
      } else {
      }
    });

    _loadMessages();
  }

  Future<void> _initSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    _myUserId = prefs.getString('userId') ?? '';

    if (_myUserId.isEmpty) {
    }

    _chatSignalrService = ChatSignalrService();

    await _chatSignalrService.initHub(
      conversationId: widget.conversationId,
      onReceiveMessage: (data) {

        final convId = data['conversationId'] as String?;
        final senderId = data['senderId'] as String?;
        final content = data['content'] as String?;
        final sentAt = data['sentAt'] as String?;
        final rawType = data['type'];

        if (convId == null || senderId == null) return;
        if (convId != widget.conversationId) return;

        String messageType = 'Text';
        List<String> images = [];

        switch (rawType) {
          case 0:
            messageType = 'Text';
            break;
          case 1:
            messageType = 'Image';
            if (content != null && content.isNotEmpty) {
              images = [content];
            }
            break;
          case 2:
            messageType = 'Images';
            if (data['images'] != null && data['images'] is List) {
              images = List<String>.from(data['images']);
            } else if (content != null) {
              try {
                final List<dynamic> list = jsonDecode(content);
                images = List<String>.from(list);
              } catch (_) {}
            }
            break;
        }

        // 🔍 Tìm avatar từ tin nhắn cũ cùng sender
        final existingSender = _messages
            .map((m) => m.sender)
            .firstWhere(
              (s) => s.id == senderId,
          orElse: () => Sender(id: senderId, name: senderId),
        );

        setState(() {
          _messages.insert(
            0,
            ConversationMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              conversationId: widget.conversationId,
              type: messageType,
              sender: existingSender,
              content: content ?? '',
              images: images,
              sentAt: sentAt ?? DateTime.now().toIso8601String(),
            ),
          );
        });

      },

    );

  }

  Future<List<String>> pickAndUploadImages() async {
    final picker = ImagePicker();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final mediaRepo = MediaRepository(MediaService(ApiClient()));

    // Chọn nhiều ảnh
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return [];

    List<String> uploadedUrls = [];

    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      try {
        final uploadRes = await mediaRepo.uploadFile(token, file);
        if (uploadRes.data != null && uploadRes.data!.url.isNotEmpty) {
          uploadedUrls.add(uploadRes.data!.url);
        }
      } catch (e) {
        //
      }
    }

    return uploadedUrls;
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _loadingUser = true;
      _userError = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _loadingUser = false;
        _userError = true;
      });
      return;
    }

    try {
      final repo = AuthRepository(AuthService(ApiClient()));
      final user = await repo.me(token);
      if (!mounted) return;

      // Lưu userId vào prefs
      await prefs.setString('userId', user.id);

      setState(() {
        _currentUserId = user.id;
        _myUserId = user.id;
        _loadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingUser = false;
        _userError = true;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final repo = ConversationRepository(ConversationService(ApiClient()));

      int page = 1;
      final List<ConversationMessage> allMessages = [];

      while (true) {
        final res = await repo.getMessages(
          token: token,
          conversationId: widget.conversationId,
          pageNumber: page,
          pageSize: _pageSize,
        );

        allMessages.addAll(res.items);
        if (!res.hasNextPage) break;
        page++;
      }

      setState(() {
        _messages = allMessages.reversed.toList();
        _hasNextPage = false;
      });
    } catch (e) {
//
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const colorPrimary = Color(0xFF2563EB);

    return Scaffold(
      body: Stack(
        children: [
          // ==== LAYER 1: Nội dung chính ====
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMine = _currentUserId != null && msg.sender.id == _currentUserId;

                    // Lấy ngày của tin nhắn hiện tại
                    final currentDate = DateTime.tryParse(msg.sentAt)?.toLocal();
                    DateTime? nextDate;
                    if (index < _messages.length - 1) {
                      nextDate = DateTime.tryParse(_messages[index + 1].sentAt)?.toLocal();
                    }

                    // Nếu là tin đầu tiên hoặc khác ngày so với tin kế tiếp (vì reverse:true)
                    bool showDateSeparator = false;
                    if (currentDate != null) {
                      if (nextDate == null ||
                          currentDate.year != nextDate.year ||
                          currentDate.month != nextDate.month ||
                          currentDate.day != nextDate.day) {
                        showDateSeparator = true;
                      }
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: isMine
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isMine)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: (msg.sender.avatarUrl == null ||
                                      msg.sender.avatarUrl!.isEmpty)
                                      ? Colors.grey
                                      : Colors.transparent,
                                  backgroundImage: (msg.sender.avatarUrl != null &&
                                      msg.sender.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(msg.sender.avatarUrl!)
                                      : null,
                                  child: (msg.sender.avatarUrl == null ||
                                      msg.sender.avatarUrl!.isEmpty)
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                              if (!isMine) const SizedBox(width: 8),
                              Flexible(
                                child: ChatBubble(
                                  message: msg,
                                  isMine: isMine,
                                  isDark: Theme.of(context).brightness == Brightness.dark,
                                  colorPrimary: const Color(0xFF2563EB),
                                  activeMessageId: _showTimeMessageId,
                                  onTap: () {
                                    setState(() {
                                      _showTimeMessageId =
                                      (_showTimeMessageId == msg.id) ? null : msg.id;
                                    });
                                  },
                                ),
                              ),
                              if (isMine) const SizedBox(width: 8),
                              if (isMine)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: (msg.sender.avatarUrl == null ||
                                      msg.sender.avatarUrl!.isEmpty)
                                      ? Colors.grey
                                      : Colors.transparent,
                                  backgroundImage: (msg.sender.avatarUrl != null &&
                                      msg.sender.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(msg.sender.avatarUrl!)
                                      : null,
                                  child: (msg.sender.avatarUrl == null ||
                                      msg.sender.avatarUrl!.isEmpty)
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                            ],
                          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
                        ),

                        // Hiển thị nhóm ngày ở giữa
                        if (showDateSeparator && currentDate != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(thickness: 1, color: Colors.grey),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    formatDateSeparator(currentDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(thickness: 1, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );

                  },
                ),
              ),

              // ==== Input area ====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // GỬI ẢNH
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _isUploadingImages
                          ? null
                          : () async {
                        setState(() => _isUploadingImages = true);
                        final imageUrls = await pickAndUploadImages();
                        setState(() => _isUploadingImages = false);

                        if (imageUrls.isEmpty) return;
                        if (_myUserId.isEmpty) return;

                        try {
                          await _chatSignalrService.sendImageMessage(
                            conversationId: widget.conversationId,
                            senderId: _myUserId,
                            imageUrls: imageUrls,
                          );

                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        } catch (e) {
                          //
                        }
                      },
                    ),

                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isUploadingImages, // khóa nhập khi đang tải ảnh
                        decoration: InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF3F3F3),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF2563EB),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isUploadingImages
                            ? null
                            : () async {
                          final text = _messageController.text.trim();
                          if (text.isEmpty) return;

                          try {
                            await _chatSignalrService.sendTextMessage(
                              conversationId: widget.conversationId,
                              senderId: _myUserId,
                              content: text,
                            );

                            _messageController.clear();
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          } catch (e) {
                            //
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ==== LAYER 2: Overlay loading khi đang upload ảnh ====
          if (_isUploadingImages)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true, // chặn tương tác
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải ảnh lên...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String formatDateSeparator(DateTime date) {
  final localDate = date.toLocal();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final msgDay = DateTime(localDate.year, localDate.month, localDate.day);

  if (msgDay == today) return 'Hôm nay';
  if (msgDay == yesterday) return 'Hôm qua';

  final diff = today.difference(msgDay).inDays;
  if (diff < 7 && diff > 0) {
    const weekdays = [
      '', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
    ];
    return weekdays[msgDay.weekday];
  }

  return '${msgDay.day.toString().padLeft(2, '0')}/${msgDay.month.toString().padLeft(2, '0')}/${msgDay.year}';
}

