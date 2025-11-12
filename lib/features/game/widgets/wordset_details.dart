import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../data/models/wordsets/word_sets_model.dart';
import '../../../data/repositories/wordset_repository.dart';
import '../../../data/services/apis/wordset_service.dart';
import '../../../core/api/api_client.dart';
import '../../../../routes/app_routes.dart';

class WordSetDetails extends StatefulWidget {
  final String wordSetId;

  const WordSetDetails({super.key, required this.wordSetId});

  @override
  State<WordSetDetails> createState() => _WordSetDetailsState();
}

class _WordSetDetailsState extends State<WordSetDetails> {
  WordSetModel? _wordSet;
  bool _loading = true;
  String? _error;
  late final WordSetRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = WordSetRepository(WordSetService(ApiClient()));
    _loadWordSet();
  }

  Future<void> _loadWordSet() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = "Token missing";
      });
      return;
    }

    try {
      final res = await _repo.getWordSetById(
        token: token,
        id: widget.wordSetId,
      );
      if (!mounted) return;
      setState(() {
        _wordSet = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onPlayPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final startResponse = await _repo.startWordSet(
        token: token,
        wordSetId: widget.wordSetId,
      );

        final wordSetData = startResponse?.data;
        if (wordSetData != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.play,
            arguments: {'startData': wordSetData},
          );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Start game returned empty data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to start game: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadWordSet,
              child: Text(loc.translate("retry")),
            ),
          ],
        ),
      );
    }
    if (_wordSet == null)
      return Center(
        child: Text(
          loc.translate("no_data"),
          style: theme.textTheme.bodyMedium,
        ),
      );

    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = Colors.grey;
    final cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // createdAt + averageRating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(_wordSet!.createdAt),
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      _wordSet!.averageRating.toStringAsFixed(1),
                      style: TextStyle(color: secondaryText, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _wordSet!.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),

            // Description
            Text(
              _wordSet!.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 16),

            // Avatar + Creator Name
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _wordSet!.creator.avatarUrl != null &&
                      _wordSet!.creator.avatarUrl!.isNotEmpty
                      ? NetworkImage(_wordSet!.creator.avatarUrl!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: (_wordSet!.creator.avatarUrl == null ||
                      _wordSet!.creator.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 18, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _wordSet!.creator.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textColor),
                    ),
                    Text(
                      'Creator',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estimated & Average Time
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Est: ${_wordSet!.estimatedTimeInMinutes} min',
                    style: TextStyle(fontSize: 12, color: secondaryText),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Avg: ${_wordSet!.averageTimeInSeconds}s',
                    style: TextStyle(fontSize: 12, color: secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // WordCount & PlayCount
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Words: ${_wordSet!.wordCount}',
                    style: TextStyle(fontSize: 12, color: secondaryText),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Plays: ${_wordSet!.playCount}',
                    style: TextStyle(fontSize: 12, color: secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tags + Go Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        String label = index == 0
                            ? _wordSet!.difficulty
                            : index == 1
                            ? _wordSet!.language.name
                            : _wordSet!.category;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onPlayPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
