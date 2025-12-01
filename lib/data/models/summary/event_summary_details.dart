class EventSummaryVocabulary {
  final String word;
  final String meaning;
  final String context;
  final List<String> examples;

  EventSummaryVocabulary({
    required this.word,
    required this.meaning,
    required this.context,
    required this.examples,
  });

  factory EventSummaryVocabulary.fromJson(Map<String, dynamic> json) {
    return EventSummaryVocabulary(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      context: json['context'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
    );
  }
}

class EventSummaryData {
  final String id;
  final String eventId;
  final String summary;
  final List<String> keyPoints;
  final List<EventSummaryVocabulary> vocabulary;
  final List<String> actionItems;
  final String createdAt;
  final bool hasSummary;

  EventSummaryData({
    required this.id,
    required this.eventId,
    required this.summary,
    required this.keyPoints,
    required this.vocabulary,
    required this.actionItems,
    required this.createdAt,
    required this.hasSummary,
  });

  factory EventSummaryData.fromJson(Map<String, dynamic> json) {
    return EventSummaryData(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      summary: json['summary'] ?? '',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      vocabulary: (json['vocabulary'] as List<dynamic>? ?? [])
          .map((e) => EventSummaryVocabulary.fromJson(e))
          .toList(),
      actionItems: List<String>.from(json['actionItems'] ?? []),
      createdAt: json['createdAt'] ?? '',
      hasSummary: json['hasSummary'] ?? false,
    );
  }
}

class EventSummaryResponse {
  final EventSummaryData data;
  final String message;

  EventSummaryResponse({
    required this.data,
    required this.message,
  });

  factory EventSummaryResponse.fromJson(Map<String, dynamic> json) {
    return EventSummaryResponse(
      data: EventSummaryData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
