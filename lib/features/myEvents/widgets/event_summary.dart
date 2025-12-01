import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/summary/event_summary_details.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';
import '../../../core/api/api_client.dart';

class EventSummary extends StatelessWidget {
  final String eventId;
  final String token;

  const EventSummary({
    super.key,
    required this.eventId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final loc = AppLocalizations.of(context);
    final repository = EventRepository(EventService(ApiClient()));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('summary_and_vocabulary') ),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: SafeArea(
        child: FutureBuilder<EventSummaryData?>(
          future: repository.getEventSummary(token, eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("${loc.translate('error_loading_summary')} ${snapshot.error}"));
            }
            final data = snapshot.data;
            if (data == null || !data.hasSummary) {
              return Center(child: Text(loc.translate('no_summary_available')));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(sw(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Khung 1: Tóm tắt cuộc họp
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw(context, 20)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(sw(context, 16)),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.summarize, size: 24, color: Colors.blue),
                            SizedBox(width: sw(context, 8)),
                            Text(
                              loc.translate('meeting_summary'),
                              style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: st(context, 18),
                                  color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        SizedBox(height: sh(context, 12)),
                        Text(
                          data.summary,
                          style: t.bodyMedium?.copyWith(color: textColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sh(context, 20)),

                  // Khung 2: Điểm chính
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw(context, 20)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(sw(context, 16)),
                      border: Border.all(color: Colors.orange.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 24, color: Colors.orange),
                            SizedBox(width: sw(context, 8)),
                            Text(
                              loc.translate('key_points'),
                              style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: st(context, 18),
                                  color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                        SizedBox(height: sh(context, 12)),
                        Column(
                          children: data.keyPoints.map((point) {
                            final index = data.keyPoints.indexOf(point);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 20, color: Colors.orange),
                                  SizedBox(width: sw(context, 8)),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: t.bodyMedium?.copyWith(color: textColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sh(context, 20)),

                  // Khung 3: Từ vựng
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw(context, 20)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(sw(context, 16)),
                      border: Border.all(color: Colors.purple.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.book_outlined, size: 24, color: Colors.purple),
                            SizedBox(width: sw(context, 8)),
                            Text(
                              loc.translate('vocabulary'),
                              style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: st(context, 18),
                                  color: Colors.purple.shade700),
                            ),
                          ],
                        ),
                        SizedBox(height: sh(context, 12)),
                        SizedBox(
                          height: sh(context, 200),
                          child: ListView.builder(
                            itemCount: data.vocabulary.length,
                            itemBuilder: (context, index) {
                              final vocab = data.vocabulary[index];
                              final Gradient wordGradient = isDark
                                  ? const LinearGradient(
                                colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : const LinearGradient(
                                colors: [Colors.white, Colors.white],
                              );
                              return GestureDetector(
                                onTap: () {
                                  final Gradient cardBackground = isDark
                                      ? const LinearGradient(
                                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : const LinearGradient(colors: [Colors.white, Colors.white]);
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        padding: EdgeInsets.all(sw(context, 20)),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(sw(context, 16)),
                                          gradient: cardBackground,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vocab.word,
                                              style: t.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor),
                                            ),
                                            SizedBox(height: sh(context, 12)),
                                            Text(
                                              "${loc.translate('context')}: ${vocab.context}",
                                              style: t.bodyMedium?.copyWith(color: textColor),
                                            ),
                                            SizedBox(height: sh(context, 12)),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: vocab.examples
                                                  .map((e) => Text("- $e",
                                                  style: t.bodyMedium?.copyWith(
                                                      color: textColor)))
                                                  .toList(),
                                            ),
                                            SizedBox(height: sh(context, 12)),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(loc.translate('close')),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: sh(context, 6)),
                                  padding: EdgeInsets.all(sw(context, 12)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(sw(context, 12)),
                                    gradient: wordGradient,
                                  ),
                                  child: Row(
                                    children: [
                                      // Số thứ tự (màu mờ, không in đậm)
                                      Text(
                                        "${index + 1}. ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: st(context, 16),
                                          color: textColor.withOpacity(0.6),  // mờ
                                        ),
                                      ),

                                      // Từ vựng + dấu :
                                      Text(
                                        vocab.word,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: st(context, 16),
                                          color: textColor,
                                        ),
                                      ),

                                      SizedBox(width: sw(context, 12)),

                                      // Nghĩa — căn lề phải
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            vocab.meaning,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Khung 4: Mục tiêu
                  if (data.actionItems.isNotEmpty) ...[
                    SizedBox(height: sh(context, 20)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw(context, 20)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(sw(context, 16)),
                        border: Border.all(color: Colors.green.shade300, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flag_outlined,
                                  size: 24, color: Colors.green),
                              SizedBox(width: sw(context, 8)),
                              Text(
                                loc.translate('action_items'),
                                style: t.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: st(context, 18),
                                    color: Colors.green.shade700),
                              ),
                            ],
                          ),
                          SizedBox(height: sh(context, 12)),
                          Column(
                            children: data.actionItems.map((item) {
                              final index = data.actionItems.indexOf(item);
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.green.shade400,
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(width: sw(context, 8)),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: t.bodyMedium?.copyWith(color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: sh(context, 20)),

                  // Dòng text cuối

                  Center(
                    child: Text(
                          () {
                        try {
                          final createdAtUtc = DateTime.parse(data.createdAt);
                          final createdAtLocal = createdAtUtc.toLocal();
                          return DateFormat('dd MMM yyyy, HH:mm').format(createdAtLocal);
                        } catch (_) {
                          return data.createdAt;
                        }
                      }(),
                      style: t.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
