import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'large_qa.dart';
import 'small_qa.dart';
import 'utils/dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final database = await _initDatabase();
  if (kReleaseMode) {
    await dotenv.load(fileName: "assets/config/.env.prod");
  } else {
    await dotenv.load(fileName: "assets/config/.env");
  }
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

  MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요리문답',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(database: database),
    );
  }
}

class MainScreen extends StatelessWidget {
  final Database database;

  MainScreen({required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.brown.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '웨스터민스터',
                style: TextStyle(
                  fontSize: 30,
                  color: const Color.fromARGB(255, 166, 121, 38),
                  fontWeight: FontWeight.w100,
                  letterSpacing: 2,
                ),
              ),
              Text(
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
                  simpleDialogue(context, '후원', '아직 구현되지 않은 기능입니다.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
