class UpdateEventStatusRequest {
  final String eventId;
  final String status;
  final String? adminNote;

  UpdateEventStatusRequest({
    required this.eventId,
    required this.status,
    this.adminNote,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'status': status,
    if (adminNote != null) 'adminNote': adminNote,
  };
}
