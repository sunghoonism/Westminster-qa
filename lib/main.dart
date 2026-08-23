import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'large_qa.dart';
import 'small_qa.dart';
import 'utils/app_style.dart';
import 'utils/donation_dialog.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15(SDK 35)부터 edge-to-edge가 강제되므로,
  // 이전 버전에서도 동일하게 동작하도록 명시적으로 활성화한다.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 모바일 광고 초기화
  final RequestConfiguration requestConfiguration = RequestConfiguration(
    maxAdContentRating: MaxAdContentRating.g,
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
  );
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  await MobileAds.instance.initialize();
  
  // 환경 파일 로드
  if (kReleaseMode) {
    await dotenv.load(fileName: "assets/config/.env.prod").catchError((e) {
      // 프로덕션 환경 파일이 없으면 일반 환경 파일 로드
      return dotenv.load(fileName: "assets/config/.env");
    });
  } else {
    await dotenv.load(fileName: "assets/config/.env");
  }
  
  final database = await _initDatabase();
  runApp(MyApp(database: database));
}

Future<Database> _initDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'west_qa.db');
  final exists = await File(path).exists();
  if (!exists) {
    ByteData data = await rootBundle.load('assets/west_qa.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
  return await openDatabase(
    path,
    onCreate: (db, version) async {},
    version: 1,
    onUpgrade: (db, oldVersion, newVersion) {
      // DB 업데이트 로직 추가
    },
  );
}

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요리문답',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: AppStyle.bodyColor,
        // 타이틀 영역을 본문보다 진하게 해 경계를 분명히 한다.
        appBarTheme: const AppBarTheme(
          backgroundColor: AppStyle.appBarColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: MainScreen(database: database),
    );
  }
}

class MainScreen extends StatelessWidget {
  final Database database;

  const MainScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    // 배경이 어두우므로 edge-to-edge에서 상태표시줄 아이콘을 밝게 유지한다.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.brown.shade900],
            ),
          ),
          // 그라데이션은 화면 전체를 덮고, 내용만 시스템 바를 피한다.
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '웨스터민스터',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color.fromARGB(255, 166, 121, 38),
                      fontWeight: FontWeight.w100,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    '대소요리문답',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                QALargePage(database: database, title: '대요리문답')),
                      );
                    },
                    child: const Text('대요리문답',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                QASmallPage(database: database, title: '소요리문답')),
                      );
                    },
                    child: const Text('소요리문답',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    child: const Text('후원을 원하신다면',
                        style: TextStyle(fontSize: 14, color: Colors.white70)),
                    onPressed: () {
                      DonationDialog.show(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
