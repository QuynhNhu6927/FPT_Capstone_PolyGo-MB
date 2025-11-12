import 'package:polygo_mobile/data/models/wordsets/start_wordset_response.dart';

class PlayWordResponse {
  final PlayWordData data;
  final String message;

  PlayWordResponse({required this.data, required this.message});

  factory PlayWordResponse.fromJson(Map<String, dynamic> json) {
    return PlayWordResponse(
      data: PlayWordData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class PlayWordData {
  final bool isCorrect;
  final bool isCompleted;
  final int currentWordIndex;
  final int totalWords;
  final int mistakes;
  final int hintsUsed;
  final int score;
  final int xpEarned;
  final int completionTimeInSeconds;
  final Word? nextWord;

  PlayWordData({
    required this.isCorrect,
    required this.isCompleted,
    required this.currentWordIndex,
    required this.totalWords,
    required this.mistakes,
    required this.hintsUsed,
    required this.score,
    required this.xpEarned,
    required this.completionTimeInSeconds,
    this.nextWord,
  });

  factory PlayWordData.fromJson(Map<String, dynamic> json) {
    return PlayWordData(
      isCorrect: json['isCorrect'],
      isCompleted: json['isCompleted'],
      currentWordIndex: json['currentWordIndex'],
      totalWords: json['totalWords'],
      mistakes: json['mistakes'],
      hintsUsed: json['hintsUsed'],
      score: json['score'],
      xpEarned: json['xpEarned'],
      completionTimeInSeconds: json['completionTimeInSeconds'],
      nextWord: json['nextWord'] != null ? Word.fromJson(json['nextWord']) : null,
    );
  }
}
