import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/play_info.dart';
import '../widgets/play_card.dart';
import '../../../data/models/wordsets/start_wordset_response.dart';
import '../../../data/repositories/wordset_repository.dart';
import '../../../data/services/apis/wordset_service.dart';
import '../../../core/api/api_client.dart';

class PlayScreen extends StatefulWidget {
  final WordSetData startData;

  const PlayScreen({super.key, required this.startData});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late WordSetData startData;
  late WordSetRepository _repo;

  late ValueNotifier<int> progressNotifier;
  late ValueNotifier<int> mistakesNotifier;
  late ValueNotifier<int> hintsNotifier;
  late ValueNotifier<bool> isCompletedNotifier;

  @override
  void initState() {
    super.initState();
    startData = widget.startData;
    _repo = WordSetRepository(WordSetService(ApiClient()));
    progressNotifier = ValueNotifier(startData.currentWordIndex);
    mistakesNotifier = ValueNotifier(0);
    hintsNotifier = ValueNotifier(0);
    isCompletedNotifier = ValueNotifier(false);
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chưa hoàn thành"),
        content: const Text("Bạn chưa chơi xong. Bạn có muốn thoát không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Thoát"),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Play Game"),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            PlayInfoRowWidget(
              startData: startData,
              progressNotifier: progressNotifier,
              mistakesNotifier: mistakesNotifier,
              hintsNotifier: hintsNotifier,
              isCompletedNotifier: isCompletedNotifier,
            ),
            const SizedBox(height: 12),
            PlayCardWidget(
              startData: startData,
              repo: _repo,
              progressNotifier: progressNotifier,
              mistakesNotifier: mistakesNotifier,
              hintsNotifier: hintsNotifier,
              isCompletedNotifier: isCompletedNotifier,
            ),
          ],
        ),
      ),
    );
  }
}
