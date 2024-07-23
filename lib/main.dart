import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:modu_messenger_firebase/screens/common/splash_screen.dart';
import 'package:provider/provider.dart';
import 'api/apis.dart';
import 'firebase_options.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                             앱 실행 메인 화면                              ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
// 전영역 크기 관리 mq (Media Query) 초기화
late Size mq;

// Initialize-Firebase (firebase 초기화)
_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async{
  // WidgetFlutterBinding 인스턴스 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // firebase 초기화
  await _initializeFirebase();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (c) => MainStore()),
    ],
    child: MaterialApp(
      // 현지화 (언어 UI) 옵션
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
          // Ripple Effect 비활성화
          splashFactory: NoSplash.splashFactory,
          // 앱바 공통 Theme
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(92, 97, 103, 1),
              centerTitle: true,
              elevation: 1,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 19,
              ),
              iconTheme: IconThemeData(color: Colors.white)),
          // 공통 폰트
          fontFamily: 'NotoSansKR',
          // 하단바 공통 Theme
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

// 전역 State <MainStore>
class MainStore extends ChangeNotifier {
  // 하단 State
  int bottomTapState = 0;

  setTapState(tap) {
    bottomTapState = tap;
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
    // 전영역 크기 관리 mq
    mq = MediaQuery.of(context).size;
    return const Center(
      // 앱 실행시 스플레시 스크린으로 이동
      child: SplashScreen(),
    );
  }
}
