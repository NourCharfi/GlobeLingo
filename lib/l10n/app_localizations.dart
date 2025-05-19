import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'ML Kit App',
      'homeTitle': 'Home',
      'ocr': 'OCR',
      'voiceTranslation': 'Voice Translation',
      'pdfTranslation': 'PDF Translation',
      'objectDetection': 'Object Detection',
      'simpleTranslation': 'Simple Translation',
      'dictionary': 'Dictionary',
      'quiz': 'Quiz',
      'settings': 'Settings',
    },
    'fr': {
      'appTitle': 'App ML Kit',
      'homeTitle': 'Accueil',
      'ocr': 'OCR',
      'voiceTranslation': 'Traduction vocale',
      'pdfTranslation': 'Traduction PDF',
      'objectDetection': "Reconnaissance d'objets",
      'simpleTranslation': 'Traduction Simple',
      'dictionary': 'Dictionnaire',
      'quiz': 'Quiz éducatif',
      'settings': 'Paramètres',
    },
    'ar': {
      'appTitle': 'تطبيق ML Kit',
      'homeTitle': 'الرئيسية',
      'ocr': 'التعرف الضوئي',
      'voiceTranslation': 'الترجمة الصوتية',
      'pdfTranslation': 'ترجمة PDF',
      'objectDetection': 'اكتشاف الكائنات',
      'simpleTranslation': 'ترجمة بسيطة',
      'dictionary': 'قاموس',
      'quiz': 'اختبار',
      'settings': 'الإعدادات',
    },
    'es': {
      'appTitle': 'App ML Kit',
      'homeTitle': 'Inicio',
      'ocr': 'OCR',
      'voiceTranslation': 'Traducción por voz',
      'pdfTranslation': 'Traducción PDF',
      'objectDetection': 'Detección de objetos',
      'simpleTranslation': 'Traducción simple',
      'dictionary': 'Diccionario',
      'quiz': 'Quiz',
      'settings': 'Configuración',
    },
    'de': {
      'appTitle': 'ML Kit App',
      'homeTitle': 'Startseite',
      'ocr': 'OCR',
      'voiceTranslation': 'Sprachübersetzung',
      'pdfTranslation': 'PDF-Übersetzung',
      'objectDetection': 'Objekterkennung',
      'simpleTranslation': 'Einfache Übersetzung',
      'dictionary': 'Wörterbuch',
      'quiz': 'Quiz',
      'settings': 'Einstellungen',
    },
    'it': {
      'appTitle': 'App ML Kit',
      'homeTitle': 'Home',
      'ocr': 'OCR',
      'voiceTranslation': 'Traduzione vocale',
      'pdfTranslation': 'Traduzione PDF',
      'objectDetection': 'Rilevamento oggetti',
      'simpleTranslation': 'Traduzione semplice',
      'dictionary': 'Dizionario',
      'quiz': 'Quiz',
      'settings': 'Impostazioni',
    },
    'pt': {
      'appTitle': 'App ML Kit',
      'homeTitle': 'Início',
      'ocr': 'OCR',
      'voiceTranslation': 'Tradução por voz',
      'pdfTranslation': 'Tradução PDF',
      'objectDetection': 'Detecção de objetos',
      'simpleTranslation': 'Tradução simples',
      'dictionary': 'Dicionário',
      'quiz': 'Quiz',
      'settings': 'Configurações',
    },
    'ru': {
      'appTitle': 'ML Kit Приложение',
      'homeTitle': 'Главная',
      'ocr': 'OCR',
      'voiceTranslation': 'Голосовой перевод',
      'pdfTranslation': 'PDF перевод',
      'objectDetection': 'Обнаружение объектов',
      'simpleTranslation': 'Простой перевод',
      'dictionary': 'Словарь',
      'quiz': 'Викторина',
      'settings': 'Настройки',
    },
    'ja': {
      'appTitle': 'ML Kitアプリ',
      'homeTitle': 'ホーム',
      'ocr': 'OCR',
      'voiceTranslation': '音声翻訳',
      'pdfTranslation': 'PDF翻訳',
      'objectDetection': '物体検出',
      'simpleTranslation': '簡単翻訳',
      'dictionary': '辞書',
      'quiz': 'クイズ',
      'settings': '設定',
    },
    'zh': {
      'appTitle': 'ML Kit应用',
      'homeTitle': '首页',
      'ocr': 'OCR',
      'voiceTranslation': '语音翻译',
      'pdfTranslation': 'PDF翻译',
      'objectDetection': '对象检测',
      'simpleTranslation': '简单翻译',
      'dictionary': '词典',
      'quiz': '测验',
      'settings': '设置',
    },
    'tr': {
      'appTitle': 'ML Kit Uygulaması',
      'homeTitle': 'Ana Sayfa',
      'ocr': 'OCR',
      'voiceTranslation': 'Sesli Çeviri',
      'pdfTranslation': 'PDF Çeviri',
      'objectDetection': 'Nesne Tespiti',
      'simpleTranslation': 'Basit Çeviri',
      'dictionary': 'Sözlük',
      'quiz': 'Quiz',
      'settings': 'Ayarlar',
    },
    'ko': {
      'appTitle': 'ML Kit 앱',
      'homeTitle': '홈',
      'ocr': 'OCR',
      'voiceTranslation': '음성 번역',
      'pdfTranslation': 'PDF 번역',
      'objectDetection': '객체 감지',
      'simpleTranslation': '간단 번역',
      'dictionary': '사전',
      'quiz': '퀴즈',
      'settings': '설정',
    },
    'hi': {
      'appTitle': 'ML Kit ऐप',
      'homeTitle': 'होम',
      'ocr': 'OCR',
      'voiceTranslation': 'वॉइस अनुवाद',
      'pdfTranslation': 'PDF अनुवाद',
      'objectDetection': 'ऑब्जेक्ट डिटेक्शन',
      'simpleTranslation': 'सरल अनुवाद',
      'dictionary': 'शब्दकोश',
      'quiz': 'प्रश्नोत्तरी',
      'settings': 'सेटिंग्स',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get homeTitle => _localizedValues[locale.languageCode]!['homeTitle']!;
  String get ocr => _localizedValues[locale.languageCode]!['ocr']!;
  String get voiceTranslation => _localizedValues[locale.languageCode]!['voiceTranslation']!;
  String get pdfTranslation => _localizedValues[locale.languageCode]!['pdfTranslation']!;
  String get objectDetection => _localizedValues[locale.languageCode]!['objectDetection']!;
  String get simpleTranslation => _localizedValues[locale.languageCode]!['simpleTranslation']!;
  String get dictionary => _localizedValues[locale.languageCode]!['dictionary']!;
  String get quiz => _localizedValues[locale.languageCode]!['quiz']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get inputTextRequired => _localizedValues[locale.languageCode]!['inputTextRequired'] ?? '';
  String get translationImpossible => _localizedValues[locale.languageCode]!['translationImpossible'] ?? '';
  String get noTextToRead => _localizedValues[locale.languageCode]!['noTextToRead'] ?? '';
  String get cannotReadTranslation => _localizedValues[locale.languageCode]!['cannotReadTranslation'] ?? '';
  String get enterTextToTranslate => _localizedValues[locale.languageCode]!['enterTextToTranslate'] ?? '';
  String get translatedText => _localizedValues[locale.languageCode]!['translatedText'] ?? '';
  String get listenTranslation => _localizedValues[locale.languageCode]!['listenTranslation'] ?? '';
  String get noTranslation => _localizedValues[locale.languageCode]!['noTranslation'] ?? '';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar', 'es', 'de', 'it', 'pt', 'ru', 'ja', 'zh', 'tr', 'ko', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
