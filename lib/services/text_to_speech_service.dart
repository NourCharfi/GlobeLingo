import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import '../widgets/modern_error_alert.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  String _mapLanguageCode(String code) {
    // Mapping simple pour le français et d'autres langues si besoin
    if (code == 'fr') return 'fr-FR';
    if (code == 'en') return 'en-US';
    // Ajoutez d'autres mappings si nécessaire
    return code;
  }

  Future<void> speak(String text, String languageCode, BuildContext context) async {
    try {
      if (text.isEmpty) {
        showModernError(context, 'Aucun texte à lire. Veuillez saisir ou traduire un texte avant d\'écouter.');
        return;
      }

      // Utiliser le mapping pour le code langue
      final mappedLanguageCode = _mapLanguageCode(languageCode);

      // Vérifier les langues supportées
      List<String> supportedLanguages = await getSupportedLanguages();
      print('Langues supportées : $supportedLanguages');
      String languageToUse = mappedLanguageCode;
      if (!supportedLanguages.contains(mappedLanguageCode)) {
        // Correction : si la langue est 'fr', on tente aussi 'fr-FR' si disponible
        if (mappedLanguageCode == 'fr-FR' && supportedLanguages.contains('fr')) {
          languageToUse = 'fr';
        }
      }
      if (!supportedLanguages.contains(languageToUse)) {
        showModernError(context, 'La langue sélectionnée ($mappedLanguageCode) n\'est pas supportée par le moteur TTS de votre appareil.\n\nPour activer la synthèse vocale en français, ouvrez les paramètres Android > Système > Langue et saisie > Synthèse vocale et sélectionnez Google Text-to-Speech comme moteur par défaut.\n\nTéléchargez la langue française si besoin.');
        return;
      }

      // Configurer la langue et forcer l'installation des données vocales
      print('Configuration de la langue : $languageToUse');
      await setLanguage(languageToUse);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0); // Toujours forcer le volume à 1.0
      await _flutterTts.setPitch(1.0);

      // Lire le texte
      print('Lecture du texte : $text');
      await _flutterTts.speak(text);
    } catch (e) {
      showModernError(context, 'Impossible de lire le texte. Merci de réessayer.');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      final mappedLanguageCode = _mapLanguageCode(languageCode);
      await _flutterTts.setLanguage(mappedLanguageCode);
      print('Langue configurée (après mapping) : $mappedLanguageCode');
    } catch (e) {
      print('Erreur lors de la configuration de la langue : $e');
      throw Exception('Impossible de configurer la langue : $languageCode');
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List<Object?>) {
        // Forcer la conversion en List<String> si possible
        return languages.map((lang) => lang.toString()).toList();
      } else if (languages is List<String>) {
        return languages;
      } else {
        throw Exception('Type inattendu pour les langues supportées : ${languages.runtimeType}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des langues supportées : $e');
      return [];
    }
  }

  Future<void> checkDefaultEngine(BuildContext context) async {
    try {
      final engine = await _flutterTts.getDefaultEngine;
      if (engine != null && engine != 'com.google.android.tts') {
        showModernError(context, 'Veuillez configurer Google Text-to-Speech comme moteur TTS par défaut pour de meilleures performances.');
      }
    } catch (e) {
      showModernError(context, 'Impossible de vérifier le moteur TTS par défaut.');
    }
  }

  Future<void> logSupportedLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      print('Langues supportées par le moteur TTS : $languages');
    } catch (e) {
      print('Erreur lors de la récupération des langues supportées : $e');
    }
  }

  void stop() {
    _flutterTts.stop();
  }

  // Pause non supportée nativement par FlutterTts, on ne fait rien ici
  void pause() {
    // Optionnel : showModernError(context, 'La pause n\'est pas supportée sur ce moteur TTS.');
  }
}