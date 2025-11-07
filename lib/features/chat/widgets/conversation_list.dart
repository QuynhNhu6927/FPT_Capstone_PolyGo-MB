import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/chat/screens/conversation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/chat/conversation_model.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/services/chat_signalr_service.dart';
import '../../../data/services/conversation_service.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final TextEditingController _searchController = TextEditingController();
  late ChatSignalrService _chatSignalrService;
  String _userId = '';

  List<Conversation> _conversations = [];
  int _pageNumber = 1;
  final int _pageSize = 10;
  bool _hasNextPage = false;
  bool _isLoading = false;
  String _searchQuery = "";

  bool _isInit = true;

  @override
  void initState() {
    super.initState();

    _chatSignalrService = ChatSignalrService();

    _loadConversations(loadMore: false).then((_) {
      _chatSignalrService.initHub();
    });

    _chatSignalrService.messageStream.listen((data) {
      final convId = data['conversationId'] as String;
      final senderId = data['senderId'] as String;
      final content = data['content'] as String?;
      final sentAt = data['sentAt'] as String?;
      final type = data['type'] is int ? data['type'] as int : 0;

      if (!mounted) return;

      setState(() {
        final index = _conversations.indexWhere((c) => c.id == convId);
        if (index != -1) {
          final conv = _conversations[index];
          conv.lastMessage = LastMessage(
            type: type,
            content: content,
            sentAt: sentAt,
            isSentByYou: senderId == _userId,
          );
          _conversations.removeAt(index);
          _conversations.insert(0, conv);
        } else {
          _conversations.insert(
            0,
            Conversation(
              id: convId,
              user: User(id: senderId, name: "Người dùng mới"),
              lastMessage: LastMessage(
                type: type,
                content: content,
                sentAt: sentAt,
                isSentByYou: senderId == _userId,
              ),
            ),
          );
        }
      });
    });
  }


  Future<void> _loadConversations({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (!loadMore) {
      _pageNumber = 1;
      _conversations = [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final repo = ConversationRepository(ConversationService(ApiClient()));
      final data = await repo.getConversationsPaged(
        token: token,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _conversations.addAll(data.items);
        _hasNextPage = data.hasNextPage;
        if (_hasNextPage) _pageNumber++;
      });

    } catch (e, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải cuộc trò chuyện: $e")),
      );
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
        _isInit = false;
      });
    }
  }

  @override
  void dispose() {
    _chatSignalrService.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const colorPrimary = Color(0xFF2563EB);

    if (_isInit) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Search + Settings
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchQuery = value.trim();
                    _loadConversations(loadMore: false);
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.settings_rounded,
                    color: isDark ? Colors.white : Colors.black87),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Open settings tapped")),
                  );
                },
              ),
            ],
          ),
        ),

        // List of conversations
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _conversations.length + (_hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _conversations.length && _hasNextPage) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () => _loadConversations(loadMore: true),
                      child: const Text("Xem thêm"),
                    ),
                  ),
                );
              }

              final conv = _conversations[index];
              final unread = conv.lastMessage.isSentByYou == false ? 1 : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          conversationId: conv.id,
                          userName: conv.user.name,
                          avatarHeader: conv.user.avatarUrl ?? '',
                        ),
                      ),
                    );
                    // _loadConversations(loadMore: false);
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: (conv.user.avatarUrl == null || conv.user.avatarUrl!.isEmpty)
                            ? Colors.grey
                            : Colors.transparent,
                        backgroundImage: (conv.user.avatarUrl != null && conv.user.avatarUrl!.isNotEmpty)
                            ? NetworkImage(conv.user.avatarUrl!)
                            : null,
                        child: (conv.user.avatarUrl == null || conv.user.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white, size: 28)
                            : null,
                      ),
                    ],
                  ),
                  title: Text(
                    conv.user.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _getLastMessageText(conv.lastMessage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),

                  trailing: Text(
                    formatConversationTime(conv.lastMessage.sentAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

String _getLastMessageText(LastMessage lastMessage) {
  final isMe = lastMessage.isSentByYou ?? false;

  switch (lastMessage.type) {
    case 0: // Text
      final content = lastMessage.content ?? '';
      return isMe ? 'Bạn: $content' : content;

    case 1: // 1 ảnh
      return isMe ? 'Bạn: đã gửi 1 ảnh' : 'Đã gửi 1 ảnh';

    case 2:
      int count = 0;
      if (lastMessage.content != null && lastMessage.content!.isNotEmpty) {
        try {
          final decoded = lastMessage.content!;
          final list = jsonDecode(decoded);
          if (list is List) {
            count = list.length;
          } else {
            count = 1;
          }
        } catch (e) {
          debugPrint('decode lastMessage.content failed: $e');
          count = 1;
        }
      }
      return isMe ? 'Bạn: đã gửi nhiều ảnh' : 'Đã gửi nhiều ảnh';

    default:
      final content = lastMessage.content ?? '';
      return isMe ? 'Bạn: $content' : content;
  }
}


String formatConversationTime(String? sentAt) {
  if (sentAt == null || sentAt.isEmpty) return '';

  final date = DateTime.tryParse(sentAt)?.toLocal();
  if (date == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final messageDay = DateTime(date.year, date.month, date.day);

  if (messageDay == today) {
    return DateFormat('HH:mm').format(date);
  } else {
    // Thứ 2 = Monday = 1, Sunday = 7
    const weekdays = [
      '', // placeholder
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return weekdays[date.weekday];
  }
}


