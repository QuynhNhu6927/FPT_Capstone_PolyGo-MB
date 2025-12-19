import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:polygo_mobile/features/users/widgets/event/user_event_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../data/models/events/user_hosted_event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/event_service.dart';
import '../../../shared/app_error_state.dart';

class HostedEventsPage extends StatefulWidget {
  final String userId;

  const HostedEventsPage({
    super.key,
    required this.userId,
  });

  @override
  State<HostedEventsPage> createState() => _HostedEventsPageState();
}

class _HostedEventsPageState extends State<HostedEventsPage> {
  late final EventRepository _repository;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _page = 1;
  List<UserHostedEventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(
      EventService(ApiClient()),
    );
    _scrollController.addListener(_onScroll);
    _loadEvents(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents({bool reset = false}) async {
    if (_isLoadingMore || (!_hasMore && !reset)) return;

    if (reset) {
      setState(() {
        _loading = true;
        _hasError = false;
        _events.clear();
        _page = 1;
        _hasMore = true;
      });
    }

    _isLoadingMore = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final res = await _repository.getUserHostedEventsPaged(
        token,
        hostId: widget.userId,
        pageNumber: _page,
        pageSize: 10,
        name: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _events.addAll(res.items);
        _hasMore = _page < res.totalPages;
        _page++;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate("event"),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: AppErrorState(onRetry: () => _loadEvents(reset: true)),
            )
                : _events.isEmpty
                ? Center(
              child: Text(loc.translate("no_events_found")),
            )
                : MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return UserEventCard(event: _events[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
