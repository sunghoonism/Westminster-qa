import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/ad.dart';
import 'utils/dialog.dart';
import 'dart:async';

class QASmallPage extends StatefulWidget {
  final Database database;
  final String title;

  const QASmallPage({super.key, required this.database, required this.title});

  @override
  _QASmallPageState createState() => _QASmallPageState();
}

class _QASmallPageState extends State<QASmallPage> {
  List<Map<String, dynamic>> qaList = [];
  List<Map<String, dynamic>> filteredList = [];
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  double _fontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 24.0;
  bool sliderVisible = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchQAList();
    _loadBottomBannerAd();
    _loadPreferences();
    _searchController.addListener(_onSearchChanged);
    _restoreScrollOffset();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _bottomBannerAd?.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim();
      _filterList();
    });
  }

  void _filterList() {
    if (_searchText.isEmpty) {
      filteredList = List.from(qaList);
    } else {
      filteredList = qaList.where((qa) {
        final question = (qa['question'] as String).toLowerCase();
        final answer = (qa['answer'] as String).toLowerCase();
        return question.contains(_searchText.toLowerCase()) || answer.contains(_searchText.toLowerCase());
      }).toList();
    }
  }

  Future<void> _fetchQAList() async {
    final list = await widget.database.query('small');
    setState(() {
      qaList = list;
      _filterList();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? _fontSize;
    });
  }

  void _loadBottomBannerAd() {
    _bottomBannerAd = AdHelper.createBottomBannerAd();
    _bottomBannerAd?.load().then((_) {
      setState(() {
        _isBottomBannerAdLoaded = true;
      });
    });
  }

  void _onScroll() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble('small_scroll_offset', _scrollController.offset);
    });
  }

  Future<void> _restoreScrollOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final offset = prefs.getDouble('small_scroll_offset') ?? 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CircleAvatar(
              backgroundColor: _showSearchBar ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.search),
                color: _showSearchBar ? theme.colorScheme.primary : null,
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                    if (!_showSearchBar) {
                      _searchController.clear();
                    }
                  });
                },
                tooltip: '검색',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CircleAvatar(
              backgroundColor: sliderVisible ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.format_size),
                color: sliderVisible ? theme.colorScheme.primary : null,
                onPressed: () {
                  setState(() {
                    sliderVisible = !sliderVisible;
                  });
                },
                tooltip: '글자 크기 조절',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showInfo(context);
            },
            icon: const Icon(Icons.help_outline),
          )
        ],
        bottom: _showSearchBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '질문 또는 답변에서 검색',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: false,
                  interactive: true,
                  thickness: 10,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final qa = filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              qa['question'] as String,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: _fontSize),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              qa['answer'] as String,
                              style: TextStyle(fontSize: _fontSize),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (sliderVisible)
            Positioned(
              right: 16,
              top: 16,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setDouble('fontSize', 16.0);
                      setState(() {
                        _fontSize = 16.0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.refresh),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: screenHeight / 4,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: _fontSize,
                        min: _minFontSize,
                        max: _maxFontSize,
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setDouble('fontSize', _fontSize);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isBottomBannerAdLoaded
          ? AdHelper.bottomBannerAdWidget(_bottomBannerAd)
          : null,
    );
  }
}
