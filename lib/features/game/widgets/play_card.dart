import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/wordsets/play_word_response.dart';
import '../../../data/models/wordsets/start_wordset_response.dart';
import '../../../data/repositories/wordset_repository.dart';
import '../screens/overview_screen.dart';

class PlayCardWidget extends StatefulWidget {
  final WordSetData startData;
  final WordSetRepository repo;
  final ValueNotifier<int> progressNotifier;
  final ValueNotifier<int> mistakesNotifier;
  final ValueNotifier<int> hintsNotifier;

  const PlayCardWidget({
    super.key,
    required this.startData,
    required this.repo,
    required this.progressNotifier,
    required this.mistakesNotifier,
    required this.hintsNotifier,
  });

  @override
  State<PlayCardWidget> createState() => _PlayCardWidgetState();
}

class _PlayCardWidgetState extends State<PlayCardWidget> {
  late String scramble;
  late String definition;
  late String question;
  String? hint;
  late String currentWordId;
  final TextEditingController _answerController = TextEditingController();
  String userAnswer = "";
  bool showAnswer = false;
  bool hintUsed = false;

  final colorPrimary = const Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _loadCurrentWord();
  }

  void _loadCurrentWord() {
    final currentWord = widget.startData.currentWord;
    question = currentWord.scrambledWord;
    scramble = currentWord.scrambledWord;
    definition = currentWord.definition;
    hint = null;
    hintUsed = false;
    currentWordId = currentWord.id;
  }

  Future<void> submitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      final data = await widget.repo.playWord(
        token: token,
        wordSetId: widget.startData.wordSetId,
        wordId: currentWordId,
        answer: answer,
      );

      if (data == null) return;

      if (data.isCorrect) {
        widget.progressNotifier.value++;
        _answerController.clear();
        userAnswer = '';

        final nextWord = data.nextWord;
        if (nextWord != null) {
          setState(() {
            question = nextWord.scrambledWord;
            scramble = nextWord.scrambledWord;
            definition = nextWord.definition;
            hint = nextWord.hint;
            hintUsed = false;
            userAnswer = '';
            currentWordId = nextWord.id;
            showAnswer = false;
          });
        } else {
          // Hết từ -> show dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("🎉 Congratulations!"),
              content: const Text("You have completed the word set."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OverviewScreen(id: widget.startData.wordSetId),
                      ),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        widget.mistakesNotifier.value++;
        _answerController.clear();
        userAnswer = '';
        setState(() => showAnswer = true);
      }
    } catch (e, st) {
      debugPrint("Failed to submit answer: $e\n$st");
    }
  }
  Future<void> showHintOnce() async {
    if (hintUsed) return; // chỉ dùng hint 1 lần
    hintUsed = true;

    setState(() {
      hint = "Loading hint...";
    });

    try {
      // Lấy token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final wordSetId = widget.startData.wordSetId;

      if (token.isEmpty) {
        setState(() {
          hint = "No token available";
        });
        return;
      }

      // Gọi API game-state để lấy hint
      final response = await widget.repo.getHint(token: token, wordSetId: wordSetId);

      // Check response
      if (response == null || response.data == null || response.data.currentWord == null) {
        setState(() {
          hint = "No hint available";
        });
        return;
      }

      // Lấy hint từ currentWord
      final apiHint = response.data.currentWord.hint;

      setState(() {
        hint = apiHint ?? "No hint available";
        widget.hintsNotifier.value++; // tăng count hint đã dùng
      });
    } catch (e, st) {
      debugPrint("Error fetching hint: $e\n$st");
      setState(() {
        hint = "Failed to load hint";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final cardBg = isDark
        ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sw(context, 16)),
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          gradient: cardBg,
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: Text(
                    "Scramble word",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: showHintOnce,
                    icon: Icon(
                      Icons.lightbulb_outline,
                      color: hintUsed ? Colors.grey : Colors.amber,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh(context, 12)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: sw(context, 8),
              children: scramble
                  .split('')
                  .map((c) => Container(
                padding: EdgeInsets.all(sw(context, 12)),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(sw(context, 8)),
                ),
                child: Text(c, style: const TextStyle(color: Colors.white)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            Text(definition, textAlign: TextAlign.center, style: TextStyle(color: textColor)),
            const SizedBox(height: 8),

            // Hiển thị hint nếu có
            if (hint != null)
              Container(
                margin: EdgeInsets.only(top: sh(context, 8)),
                padding: EdgeInsets.all(sw(context, 8)),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(sw(context, 8)),
                ),
                child: Text(hint!, style: const TextStyle(color: Colors.black)),
              ),

            SizedBox(height: sh(context, 30)),
            TextField(
              controller: _answerController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Type the word here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw(context, 8))),
              ),
            ),
            SizedBox(height: sh(context, 16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw(context, 8))),
                ),
                child: const Text("Submit Answer", style: TextStyle(color: Colors.white)),
              ),
            ),
            if (showAnswer)
              Padding(
                padding: EdgeInsets.only(top: sh(context, 16)),
                child: Text(
                  userAnswer.toUpperCase() == question.toUpperCase() ? "✅ Correct!" : "❌ Try again",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: userAnswer.toUpperCase() == question.toUpperCase()
                          ? Colors.green
                          : Colors.red),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
