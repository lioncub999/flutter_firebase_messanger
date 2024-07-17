import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/screens/common/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                    Main.dart                                     ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
late Size mq; // Global Size Management (Media Query)

// Initialize-Firebase (firebase 초기화)
_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // WidgetFlutterBinding 인스턴스 초기화
  _initializeFirebase(); // firebase 초기화
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (c) => MainStore()),
    ],
    child: MaterialApp(
      // 현지화 옵션
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Material Design 위젯 현지화
        GlobalWidgetsLocalizations.delegate, // 일반 Flutter 위젯 현지화
        GlobalCupertinoLocalizations.delegate, // Cupertino 위젯 현지화
      ],
      // 지원 언어 및 지역
      supportedLocales: const [
        Locale('ko', ''), // 한국어
        Locale('en', ''), // 영어
      ],
      // 전체 공통 Theme
      theme: ThemeData(
          splashFactory: NoSplash.splashFactory, // Ripple Effect 비활성화
          // AppBar-Theme
          appBarTheme: const AppBarTheme(
              backgroundColor: const Color.fromRGBO(92, 97, 103, 1),
              centerTitle: true,
              elevation: 1,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 19,
              ),
              iconTheme: IconThemeData(color: Colors.white)),
          fontFamily: 'NotoSansKR',
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(92, 97, 103, 1),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            // 선택 요소 라벨 보이기
            showSelectedLabels: true,
            // 미선택 요소 라벨 가리기
            showUnselectedLabels: false,
          )),
      home: const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Global 변수 관리
class MainStore extends ChangeNotifier {
  // Tab State
  int tapState = 0;

  setTapState(tap) {
    tapState = tap;
    notifyListeners();
  }
}

class _MyAppState extends State<MyApp> {
  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Global Size Management (Media Query)
    mq = MediaQuery.of(context).size;
    return const Center(
      child: SplashScreen(),
    );
  }
}
