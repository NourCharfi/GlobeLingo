import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/ocr_translation_screen.dart';
import 'screens/voice_translation_screen.dart';
import 'screens/pdf_translation_screen.dart';
import 'screens/object_detection_screen.dart';
import 'screens/simple_translation_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/yolo_detection_screen.dart';
import 'screens/quiz_screen.dart';
import 'theme_provider.dart';
import 'widgets/main_scaffold.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const Color _darkBackground = Color(0xFF000000);
  static const Color _darkPrimary = Color(0xFF0D253F);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'App ML Kit',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
        Locale('es'),
        Locale('de'),
        Locale('it'),
        Locale('pt'),
        Locale('ru'),
        Locale('ja'),
        Locale('zh'),
        Locale('tr'),
        Locale('ko'),
        Locale('hi'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue[800],
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue[800]!,
          secondary: Colors.blue[400]!,
          background: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        cardColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue[800]),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.blue[900],
          displayColor: Colors.blue[900],
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.blue[800]),
          prefixIconColor: Colors.blue[800],
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101426), // fond général très foncé
        primaryColor: const Color(0xFF1B2342), // bleu foncé pour les éléments principaux
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF2979FF), // bleu vif pour les accents
          secondary: const Color(0xFF64B5F6), // bleu clair pour les accents secondaires
          background: const Color(0xFF101426),
          surface: const Color(0xFF232A3E), // pour les cards et champs
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B2342),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2979FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        cardColor: const Color(0xFF232A3E),
        iconTheme: IconThemeData(color: const Color(0xFF64B5F6)),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF232A3E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: const Color(0xFF64B5F6)),
          prefixIconColor: const Color(0xFF64B5F6),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: SplashScreen(),
      routes: {
        '/home': (context) => MainScaffold(initialIndex: 0),
        '/quiz': (context) => MainScaffold(initialIndex: 1),
        '/settings': (context) => MainScaffold(initialIndex: 2),
        '/simple': (context) => SimpleTranslationScreen(),
        '/ocr': (context) => OCRTranslationScreen(),
        '/voice': (context) => VoiceTranslationScreen(),
        '/pdf': (context) => PDFTranslationScreen(),
        '/object': (context) => ObjectDetectionScreen(),
        '/dictionary': (context) => DictionaryScreen(),
        '/quiz': (context) => QuizScreen(), 
    
      },
    );
  }
}
