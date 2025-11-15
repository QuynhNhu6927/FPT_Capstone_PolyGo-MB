import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/chat/conversation_message_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/signalr/chat_signalr_service.dart';
import '../../../data/services/apis/conversation_service.dart';
import '../../../data/services/apis/media_service.dart';
import 'chat_input.dart';
import 'conversation_app_bar.dart';
import 'message_item.dart';

class Conversation extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String receiverId;
  final String avatarHeader;
  final String lastActiveAt;
  final bool isOnline;

  const Conversation({
    super.key,
    required this.conversationId,
    required this.userName,
    required this.avatarHeader,
    required this.lastActiveAt,
    required this.receiverId,
    required this.isOnline,
  });

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  bool _isUploadingImages = false;
  late ChatSignalrService _chatSignalrService;
  late final StreamSubscription<Map<String, dynamic>> _messageSub;
  String? _showTimeMessageId;
  List<ConversationMessage> _messages = [];
  bool _isLoading = false;
  final int _pageSize = 20;
  FlutterSoundRecorder? _recorder;
  String? _audioFilePath;
  bool _isRecording = false;
  bool _isRecordingDone = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  String _myUserId = '';
  bool _loadingUser = false;
  bool _userError = false;

  @override
  void initState() {
    super.initState();
    _initConversation();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> _initConversation() async {
    await _loadCurrentUser();
    if (_myUserId.isEmpty) return;

    await _loadMessages();

    _chatSignalrService = ChatSignalrService();
    await _chatSignalrService.joinConversation(widget.conversationId);

    _messageSub = _chatSignalrService.messageStream.listen(_handleIncomingMessage);
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
      await prefs.setString('userId', user.id);

      setState(() {
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

  Future<void> _startRecording() async {
    if (_recorder == null) return;
    final granted = await _checkMicrophonePermission();
    if (!granted) {
      debugPrint('Microphone permission denied');
      return;
    }

    final tempDir = await getTemporaryDirectory();
    _audioFilePath =
    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: _audioFilePath,
      codec: Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
      _isRecordingDone = false;
    });
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    if (_recorder == null || !_isRecording) return;

    final path = await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecordingDone = true;
    });

    if (cancel || path == null || path.isEmpty) {
      debugPrint('Recording canceled');
      _audioFilePath = null;
      return;
    }

    debugPrint('Recording finished: $path');

    // Upload và gửi audio
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final mediaRepo = MediaRepository(MediaService(ApiClient()));
    final file = File(path);
    final uploadRes = await mediaRepo.uploadAudio(token, file);
    if (uploadRes.data != null && uploadRes.data!.url.isNotEmpty) {
      await _chatSignalrService.sendAudioMessage(
        conversationId: widget.conversationId,
        senderId: _myUserId,
        audioUrl: uploadRes.data!.url,
      );
    }

    _audioFilePath = null;
    setState(() => _isRecordingDone = false);
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
      });
    } catch (e) {
      // handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    if (data['conversationId'] != widget.conversationId) return;

    final senderId = data['senderId'] ?? '';
    final senderName = data['senderName'] ?? senderId;

    String messageType = 'Text';
    List<String> images = [];

    switch (data['type']) {
      case 0:
        messageType = 'Text';
        break;
      case 1:
        messageType = 'Image';
        if (data['content'] != null) images = [data['content']];
        break;
      case 2:
        messageType = 'Images';
        if (data['images'] != null) {
          images = List<String>.from(data['images']);
        } else if (data['content'] != null) {
          try {
            images = List<String>.from(jsonDecode(data['content']));
          } catch (_) {}
        }
        break;
      case 3: // Audio
        messageType = 'Audio';
        break;
    }

    final existingSender = _messages
        .map((m) => m.sender)
        .firstWhere(
          (s) => s.id == senderId,
      orElse: () => Sender(id: senderId, name: senderName),
    );

    final sentAtStr = data['sentAt'] ?? DateTime.now().toIso8601String();
    final sentAt = DateTime.tryParse(sentAtStr)?.toLocal() ?? DateTime.now();

    setState(() {
      _messages.insert(
        0,
        ConversationMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: widget.conversationId,
          type: messageType,
          sender: existingSender,
          content: data['content'] ?? '',
          images: images,
          sentAt: sentAt.toIso8601String(),
        ),
      );
    });
  }

  Future<void> _handlePickAndUploadImages() async {
    setState(() => _isUploadingImages = true);

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final mediaRepo = MediaRepository(MediaService(ApiClient()));
      final List<String> uploadedUrls = [];

      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final uploadRes = await mediaRepo.uploadFile(token, file);
        if (uploadRes.data != null && uploadRes.data!.url.isNotEmpty) {
          uploadedUrls.add(uploadRes.data!.url);
        }
      }

      if (uploadedUrls.isNotEmpty) {
        await _chatSignalrService.sendImageMessage(
          conversationId: widget.conversationId,
          senderId: _myUserId,
          imageUrls: uploadedUrls,
        );
      }
    } catch (e) {
      debugPrint('Upload image error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImages = false);
    }
  }

  Future<void> _handleSendText(String content) async {
    if (content.trim().isEmpty || _myUserId.isEmpty) return;
    await _chatSignalrService.sendTextMessage(
      conversationId: widget.conversationId,
      senderId: _myUserId,
      content: content.trim(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageSub.cancel();
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const colorPrimary = Color(0xFF2563EB);

    return Scaffold(
      appBar: ConversationAppBar(
        receiverId: widget.receiverId,
        userName: widget.userName,
        avatarHeader: widget.avatarHeader,
        lastActiveAt: widget.lastActiveAt,
        isOnline: widget.isOnline,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = msg.sender.id == _myUserId;

                      DateTime? nextDate;
                      if (index < _messages.length - 1) {
                        nextDate = DateTime.tryParse(
                          _messages[index + 1].sentAt,
                        )?.toLocal();
                      }

                      bool showDateSeparator = false;
                      final currentDate = DateTime.tryParse(msg.sentAt)?.toLocal();
                      if (currentDate != null) {
                        if (index == _messages.length - 1) {
                          showDateSeparator = true;
                        } else {
                          final nextDate = DateTime.tryParse(_messages[index + 1].sentAt)?.toLocal();
                          if (nextDate != null &&
                              (currentDate.year != nextDate.year ||
                                  currentDate.month != nextDate.month ||
                                  currentDate.day != nextDate.day)) {
                            showDateSeparator = true;
                          }
                        }
                      }

                      return MessageItem(
                        message: msg,
                        isMine: isMine,
                        isDark: isDark,
                        colorPrimary: colorPrimary,
                        activeMessageId: _showTimeMessageId,
                        onTap: () {
                          setState(() {
                            _showTimeMessageId = (_showTimeMessageId == msg.id) ? null : msg.id;
                          });
                        },
                        showDateSeparator: showDateSeparator,
                        onDelete: (messageId) async {
                          await _chatSignalrService.deleteMessage(messageId: messageId);
                          setState(() {
                            _messages.removeWhere((m) => m.id == messageId);
                          });
                        },
                      );

                    },
                  ),
                ),
                ChatInputBar(
                  isUploadingImages: _isUploadingImages,
                  isDark: isDark,
                  colorPrimary: colorPrimary,
                  controller: _messageController,
                  scrollController: _scrollController,
                  onPickImages: _handlePickAndUploadImages,
                  onSendText: _handleSendText,
                  onStartRecording: _startRecording,
                  onStopRecording: _stopRecording,
                  isRecording: _isRecording,
                  isRecordingDone: _isRecordingDone,
                ),

              ],
            ),
          ),
          if (_isUploadingImages)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
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
