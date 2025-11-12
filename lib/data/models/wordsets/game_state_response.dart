import 'package:polygo_mobile/data/models/wordsets/start_wordset_response.dart';

class GameStateResponse {
  final GameStateData data;
  final String message;

  GameStateResponse({required this.data, required this.message});

  factory GameStateResponse.fromJson(Map<String, dynamic> json) {
    return GameStateResponse(
      data: GameStateData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class GameStateData {
  final String wordSetId;
  final int totalWords;
  final int currentWordIndex;
  final int completedWords;
  final Word currentWord;
  final String? hint;
  final int mistakes;
  final int hintsUsed;
  final int elapsedTime;
  final DateTime? startTime;

  GameStateData({
    required this.wordSetId,
    required this.totalWords,
    required this.currentWordIndex,
    required this.completedWords,
    required this.currentWord,
    this.hint,
    required this.mistakes,
    required this.hintsUsed,
    required this.elapsedTime,
    this.startTime,
  });

  factory GameStateData.fromJson(Map<String, dynamic> json) {
    return GameStateData(
      wordSetId: json['wordSetId'],
      totalWords: json['totalWords'],
      currentWordIndex: json['currentWordIndex'],
      completedWords: json['completedWords'],
      currentWord: Word.fromJson(json['currentWord']),
      hint: json['currentWord']?['hint'],
      mistakes: json['mistakes'],
      hintsUsed: json['hintsUsed'],
      elapsedTime: json['elapsedTime'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
    );
  }
}
