class VocabularyItem {
  final String word;
  final String meaning;
  final String context;
  final List<String> examples;

  VocabularyItem({
    required this.word,
    required this.meaning,
    required this.context,
    required this.examples,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      context: json['context'] ?? '',
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class AiSummaryModel {
  final String id;
  final String eventId;
  final String summary;
  final List<String> keyPoints;
  final List<VocabularyItem> vocabulary;
  final List<String> actionItems;
  final String createdAt;
  final bool hasSummary;

  AiSummaryModel({
    required this.id,
    required this.eventId,
    required this.summary,
    required this.keyPoints,
    required this.vocabulary,
    required this.actionItems,
    required this.createdAt,
    required this.hasSummary,
  });

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AiSummaryModel(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      summary: json['summary'] ?? '',
      keyPoints:
      (json['keyPoints'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      vocabulary: (json['vocabulary'] as List<dynamic>? ?? [])
          .map((e) => VocabularyItem.fromJson(e))
          .toList(),
      actionItems:
      (json['actionItems'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      createdAt: json['createdAt'] ?? '',
      hasSummary: json['hasSummary'] ?? false,
    );
  }
}

class AiSummaryResponse {
  final AiSummaryModel data;
  final String message;

  AiSummaryResponse({
    required this.data,
    required this.message,
  });

  factory AiSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AiSummaryResponse(
      data: AiSummaryModel.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
