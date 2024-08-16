import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/ad.dart';
import 'utils/dialog.dart';

class QASmallPage extends StatefulWidget {
  final Database database;
  final String title;

  const QASmallPage({super.key, required this.database, required this.title});

  @override
  _QASmallPageState createState() => _QASmallPageState();
}

class _QASmallPageState extends State<QASmallPage> {
  List<Map<String, dynamic>> qaList = [];
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  double _fontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 24.0;
  bool sliderVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchQAList();
    _loadBottomBannerAd();
    _loadPreferences();
  }

  Future<void> _fetchQAList() async {
    final list = await widget.database.query('small');
    setState(() {
      qaList = list;
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                sliderVisible = !sliderVisible;
              });
            },
            icon: const Icon(Icons.format_size),
          ),
          IconButton(
            onPressed: () {
              showInfo(context);
            },
            icon: const Icon(Icons.help_outline),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: qaList.length,
            itemBuilder: (context, index) {
              final qa = qaList[index];
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

  @override
  void dispose() {
    _bottomBannerAd?.dispose();
    super.dispose();
  }
}
