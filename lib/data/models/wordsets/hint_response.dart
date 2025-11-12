class HintResponse {
  final String wordId;
  final String hint;
  final int totalHintsUsed;

  HintResponse({
    required this.wordId,
    required this.hint,
    required this.totalHintsUsed,
  });

  factory HintResponse.fromJson(Map<String, dynamic> json) {
    return HintResponse(
      wordId: json['wordId'] as String,
      hint: json['hint'] as String,
      totalHintsUsed: json['totalHintsUsed'] as int,
    );
  }
}
