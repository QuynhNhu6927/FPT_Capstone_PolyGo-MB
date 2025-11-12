class StartWordSetResponse {
  final WordSetData data;
  final String message;

  StartWordSetResponse({required this.data, required this.message});

  factory StartWordSetResponse.fromJson(Map<String, dynamic> json) {
    return StartWordSetResponse(
      data: WordSetData.fromJson(json['data']), // chỉ lấy data
      message: json['message'] ?? '',
    );
  }

}

class WordSetData {
  final String wordSetId;
  final int totalWords;
  final int currentWordIndex;
  final Word currentWord;
  final DateTime? startTime;

  WordSetData({
    required this.wordSetId,
    required this.totalWords,
    required this.currentWordIndex,
    required this.currentWord,
    this.startTime,
  });

  factory WordSetData.fromJson(Map<String, dynamic> json) {
    return WordSetData(
      wordSetId: json['wordSetId'],
      totalWords: json['totalWords'],
      currentWordIndex: json['currentWordIndex'],
      currentWord: Word.fromJson(json['currentWord']),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
    );
  }
}

class Word {
  final String id;
  final String scrambledWord;
  final String definition;
  final String? hint;

  Word({
    required this.id,
    required this.scrambledWord,
    required this.definition,
    this.hint,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      scrambledWord: json['scrambledWord'],
      definition: json['definition'],
      hint: json['hint'],
    );
  }

  Word copyWith({
    String? id,
    String? scrambledWord,
    String? definition,
    String? hint,
  }) {
    return Word(
      id: id ?? this.id,
      scrambledWord: scrambledWord ?? this.scrambledWord,
      definition: definition ?? this.definition,
      hint: hint ?? this.hint,
    );
  }
}