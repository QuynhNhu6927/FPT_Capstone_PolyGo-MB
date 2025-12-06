import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/summary/event_summary_details.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';
import '../../../core/api/api_client.dart';

class EventSummary extends StatefulWidget {
  final String eventId;
  final String token;
  final bool isHost;

  const EventSummary({
    super.key,
    required this.eventId,
    required this.token,
    required this.isHost,
  });

  @override
  State<EventSummary> createState() => _EventSummaryState();
}

class _EventSummaryState extends State<EventSummary> {
  late final EventRepository repository;
  EventSummaryData? data;
  bool isLoading = true;
  bool isGenerating = false;
  bool hasUserTriggeredGenerate = false;
  @override
  void initState() {
    super.initState();
    repository = EventRepository(EventService(ApiClient()));
    loadSummary();
  }

  Future<void> loadSummary() async {
    setState(() => isLoading = true);

    try {
      data = await repository.getEventSummary(widget.token, widget.eventId);
    } catch (e) {
      print("❌ Load summary error: $e");
      data = null;
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> generateSummary() async {
    if (isGenerating) return;

    setState(() {
      isGenerating = true;
      hasUserTriggeredGenerate = true;
    });

    // chạy ngầm không chờ kết quả
    repository.generateSummary(
      token: widget.token,
      eventId: widget.eventId,
    ).catchError((e) {
      print("❌ Generate Summary Error: $e");
    });
  }

  void _showVocabularyDetail(EventSummaryVocabulary vocab) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Gradient gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ------- WORD -------
                  Text(
                    vocab.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ------- CONTEXT -------
                  const Text(
                    "Context",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(vocab.context, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  /// ------- EXAMPLES -------
                  const Text(
                    "Examples",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: vocab.examples.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "• $e",
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('summary_and_vocabulary')),
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, t, textColor, loc),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TextTheme t,
    Color textColor,
    AppLocalizations loc,
  ) {
    if (data == null || !data!.hasSummary) {
      if (widget.isHost) {
        if (isGenerating || hasUserTriggeredGenerate) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Đang tạo báo cáo sự kiện, xin vui lòng quay lại sau vài phút",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppButton(
              size: ButtonSize.md,
              variant: ButtonVariant.primary,
              onPressed: generateSummary,
              icon: const Icon(Icons.auto_awesome, size: 18),
              text: loc.translate('generate_event_summary'),
            ),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              loc.translate('no_summary_available'),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    final summary = data!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- SUMMARY ----------
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
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 12)),
                Text(summary.summary, style: t.bodyMedium),
              ],
            ),
          ),

          SizedBox(height: sh(context, 20)),

          /// ---------- KEY POINTS ----------
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
                    const Icon(
                      Icons.check_circle_outline,
                      size: 24,
                      color: Colors.orange,
                    ),
                    SizedBox(width: sw(context, 8)),
                    Text(
                      loc.translate('key_points'),
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 18),
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 12)),
                Column(
                  children: data!.keyPoints.map((point) {
                    final index = data!.keyPoints.indexOf(point);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.orange,
                          ),
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

          /// ---------- VOCABULARY ----------
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
                    const Icon(
                      Icons.book_outlined,
                      size: 24,
                      color: Colors.purple,
                    ),
                    SizedBox(width: sw(context, 8)),
                    Text(
                      loc.translate('vocabulary'),
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 18),
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 12)),
                SizedBox(
                  height: sh(context, 200),
                  child: ListView.builder(
                    itemCount: data!.vocabulary.length,
                    itemBuilder: (context, index) {
                      final vocab = data!.vocabulary[index];
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      final Gradient gradient = isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.white, Colors.white],
                            );

                      return GestureDetector(
                        onTap: () => _showVocabularyDetail(vocab),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: sh(context, 6),
                          ),
                          padding: EdgeInsets.all(sw(context, 12)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              sw(context, 12),
                            ),
                            gradient: gradient,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${index + 1}. ",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: st(context, 16),
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                vocab.word,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: st(context, 16),
                                  color: textColor,
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

          /// ---------- ACTION ITEMS ----------
          if (data!.actionItems.isNotEmpty) ...[
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
                      const Icon(
                        Icons.flag_outlined,
                        size: 24,
                        color: Colors.green,
                      ),
                      SizedBox(width: sw(context, 8)),
                      Text(
                        loc.translate('action_items'),
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 18),
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh(context, 12)),
                  Column(
                    children: data!.actionItems.map((item) {
                      final index = data!.actionItems.indexOf(item);
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
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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

          /// ---------- TIME ----------
          Center(
            child: Text(() {
              try {
                final createdAtUtc = DateTime.parse(data!.createdAt);
                final createdAtLocal = createdAtUtc.toLocal();
                return DateFormat('dd MMM yyyy, HH:mm').format(createdAtLocal);
              } catch (_) {
                return data!.createdAt;
              }
            }(), style: t.bodySmall?.copyWith(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
