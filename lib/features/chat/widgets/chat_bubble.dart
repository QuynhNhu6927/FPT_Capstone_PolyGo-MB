import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat/conversation_message_model.dart';

String formatTime(String sentAt) {
  if (sentAt.isEmpty) return '';
  final date = DateTime.tryParse(sentAt)?.toLocal();
  if (date == null) return '';
  return DateFormat('HH:mm').format(date);
}

class ChatBubble extends StatefulWidget {
  final ConversationMessage message;
  final bool isMine;
  final bool isDark;
  final Color colorPrimary;
  final String? activeMessageId;
  final VoidCallback onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.colorPrimary,
    this.activeMessageId,
    required this.onTap,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == "Audio") {
      _audioPlayer = AudioPlayer();

      _audioPlayer!.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });

      _audioPlayer!.onDurationChanged.listen((d) {
        if (d.inMilliseconds > 0) {
          setState(() {
            _duration = d;
          });
        }
      });

      _audioPlayer!.onPositionChanged.listen((p) {
        setState(() {
          _position = p;
        });
      });

      // **Lắng nghe khi audio kết thúc**
      _audioPlayer!.onPlayerComplete.listen((_) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      });

      // Load audio
      _loadAudio(widget.message.content);
    }
  }

  Future<void> _loadAudio(String url) async {
    try {
      await _audioPlayer!.setSourceUrl(url); // Load audio
      final d = await _audioPlayer!.getDuration();
      if (d != null && d.inMilliseconds > 0) {
        setState(() {
          _duration = d;
        });
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showTime = widget.activeMessageId == widget.message.id;

    return Column(
      crossAxisAlignment:
      widget.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showTime)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              formatTime(widget.message.sentAt),
              style: TextStyle(
                fontSize: 11,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        GestureDetector(
          onTap: widget.onTap,
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // TEXT message
    if (widget.message.type == "Text") {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: widget.isMine
              ? widget.colorPrimary.withOpacity(0.85)
              : (widget.isDark
              ? const Color(0xFF2C2C2C)
              : const Color(0xFFDFDFDF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.message.content,
          style: TextStyle(
            color: widget.isMine
                ? Colors.white
                : (widget.isDark ? Colors.white : Colors.black),
            fontSize: 14,
          ),
        ),
      );
    }

    // AUDIO message
    if (widget.message.type == "Audio") {
      final url = widget.message.content;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isMine
              ? widget.colorPrimary.withOpacity(0.85)
              : (widget.isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDFDFDF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMine ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                try {
                  if (_isPlaying) {
                    await _audioPlayer?.pause();
                  } else {
                    // Nếu audio đã kết thúc, play lại từ đầu
                    if (_position >= _duration) {
                      await _audioPlayer?.seek(Duration.zero);
                      setState(() => _position = Duration.zero);
                    }

                    // Nếu duration chưa load, load audio
                    if (_duration == Duration.zero) {
                      await _loadAudio(url);
                    }

                    // Dùng play() thay vì resume()
                    await _audioPlayer?.play(UrlSource(url));
                  }
                } catch (e) {
                  debugPrint("Audio play error: $e");
                }
              },

            ),
            Expanded(
              child: Slider(
                activeColor: widget.isMine ? Colors.white : widget.colorPrimary,
                inactiveColor: widget.isMine ? Colors.white70 : Colors.black26,
                min: 0,
                max: _duration.inMilliseconds.toDouble() > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1, // tránh chia cho 0
                value: _position.inMilliseconds
                    .toDouble()
                    .clamp(0.0, _duration.inMilliseconds.toDouble()),
                onChanged: (value) async {
                  final pos = Duration(milliseconds: value.toInt());
                  await _audioPlayer?.seek(pos);
                  setState(() => _position = pos);
                },
              ),
            ),
            Text(
              _formatDuration(_duration - _position),
              style: TextStyle(
                  color: widget.isMine ? Colors.white : Colors.black, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // IMAGE message
    final images = widget.message.images;
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _showFullImage(context, images),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: Image.network(
              images[0],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _showFullImage(context, images),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 220,
              maxHeight: 220,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: images.length == 2 ? 2 : 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: images.length > 9 ? 9 : images.length,
              itemBuilder: (context, index) {
                if (index == 8 && images.length > 9) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(images[index], fit: BoxFit.cover),
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Text(
                          '+${images.length - 9}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showFullImage(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
