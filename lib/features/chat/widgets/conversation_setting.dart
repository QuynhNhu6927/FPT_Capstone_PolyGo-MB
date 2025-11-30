import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/languages/language_model.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../data/services/apis/conversation_service.dart';
import '../../../data/services/apis/language_service.dart';

class ConversationSetting extends StatefulWidget {
  final String conversationId;

  const ConversationSetting({super.key, required this.conversationId});

  @override
  State<ConversationSetting> createState() => _ConversationSettingState();
}

class _ConversationSettingState extends State<ConversationSetting> {
  LanguageModel? _selectedLanguageModel;
  String? _currentLanguageCode;
  List<LanguageModel> _languages = [];
  bool _isLoadingLanguages = false;

  // Chat images
  final List<String> _chatImages = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLanguages();
    _loadTranslationLanguage();
    _loadImages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onLanguageChanged(LanguageModel lang) async {
    setState(() => _selectedLanguageModel = lang);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final repo = ConversationRepository(ConversationService(ApiClient()));
      final success = await repo.updateTranslationLanguage(
        token: token,
        conversationId: widget.conversationId,
        languageCode: lang.code,
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update language')),
        );
      } else {
        // update label mặc định
        setState(() {
          _currentLanguageCode = lang.code;
        });
      }
    } catch (e) {
      debugPrint("Error updating translation language: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating language')),
      );
    }
  }

  Future<void> _loadTranslationLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final repo = ConversationRepository(ConversationService(ApiClient()));
      final lang = await repo.getTranslationLanguage(
        token: token,
        conversationId: widget.conversationId,
      );

      if (lang != null && lang.effectiveLanguageCode.isNotEmpty) {
        setState(() {
          _currentLanguageCode = lang.effectiveLanguageCode;
        });
      }
    } catch (e) {
      debugPrint("Failed to load translation language: $e");
    }
  }

  Future<void> _loadLanguages() async {
    setState(() => _isLoadingLanguages = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final repo = LanguageRepository(LanguageService(ApiClient()));
      final loc = AppLocalizations.of(context);
      final currentLang = loc.locale.languageCode;
      final languages = await repo.getAllLanguages(token, lang: currentLang);
      setState(() => _languages = languages);
    } catch (e) {
      debugPrint("Error loading languages: $e");
    } finally {
      setState(() => _isLoadingLanguages = false);
    }
  }

  Future<void> _loadImages() async {
    if (_isLoading || _currentPage > _totalPages) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final repo = ConversationRepository(ConversationService(ApiClient()));
      final res = await repo.getConversationImages(
        token: token,
        conversationId: widget.conversationId,
        pageNumber: _currentPage,
        pageSize: 20,
      );

      if (res != null) {
        // tách các URL có "keyword"
        List<String> parsedImages = [];
        for (var url in res.items) {
          if (url.contains('keyword')) {
            parsedImages.addAll(url.split('keyword').where((e) => e.isNotEmpty));
          } else {
            parsedImages.add(url);
          }
        }

        setState(() {
          _chatImages.addAll(parsedImages);
          _currentPage++;
          _totalPages = res.totalPages;
        });
      }
    } catch (e) {
      debugPrint("Error loading images: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadImages();
    }
  }

  void _openImageViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewer(
          images: _chatImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('conversation_settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('choose_language_to_translate'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingLanguages
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField2<LanguageModel>(
                value: _selectedLanguageModel,
                hint: Row(
                  children: [
                    // Tìm language trong _languages theo effectiveLanguageCode
                    if (_languages.any((e) => e.code == _currentLanguageCode))
                      Image.network(
                        _languages.firstWhere((e) => e.code == _currentLanguageCode).iconUrl,
                        width: 24,
                        height: 24,
                      ),
                    if (_languages.any((e) => e.code == _currentLanguageCode))
                      const SizedBox(width: 8),
                    Text(
                      _languages.any((e) => e.code == _currentLanguageCode)
                          ? _languages.firstWhere((e) => e.code == _currentLanguageCode).name
                          : _currentLanguageCode ?? '',
                    ),
                  ],
                ),
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Row(
                      children: [
                        if (lang.iconUrl.isNotEmpty)
                          Image.network(
                            lang.iconUrl,
                            width: 24,
                            height: 24,
                          ),
                        const SizedBox(width: 8),
                        Text(lang.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (lang) {
                  if (lang == null) return;
                  _onLanguageChanged(lang);
                },
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  offset: const Offset(0, -8),
                  elevation: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.grey[800] : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Chat images title
              Text(
                loc.translate('chat_images'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Grid of chat images (scrollable)
              // Grid of chat images (scrollable)
              Expanded(
                child: _chatImages.isEmpty && !_isLoading
                    ? Center(
                  child: Text(
                    loc.translate('no_images'), // bạn có thể thêm key 'no_images' trong localization
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                )
                    : GridView.builder(
                  controller: _scrollController,
                  itemCount: _chatImages.length + (_isLoading ? 1 : 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= _chatImages.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final image = _chatImages[index];
                    return GestureDetector(
                      onTap: () => _openImageViewer(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: image != null
                              ? DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: image == null
                            ? const Icon(
                          Icons.image,
                          color: Colors.white70,
                          size: 40,
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

/// Fullscreen image viewer with swipe
class ImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewer({super.key, required this.images, required this.initialIndex});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('${_currentIndex + 1}/${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
