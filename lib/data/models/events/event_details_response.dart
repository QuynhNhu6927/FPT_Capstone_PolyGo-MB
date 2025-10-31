import 'event_details_model.dart';

class EventDetailsResponse {
  final EventDetailsModel data;
  final String message;

  EventDetailsResponse({
    required this.data,
    required this.message,
  });

  factory EventDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EventDetailsResponse(
      data: EventDetailsModel.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
