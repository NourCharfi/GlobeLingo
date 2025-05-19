import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../widgets/modern_error_alert.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();

  Future<bool> initialize(BuildContext context) async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final result = await _speechToText.initialize();
        return result;
      } else {
        showModernError(context, 'Permission micro refusée. Activez-la dans les paramètres pour utiliser la reconnaissance vocale.');
        return false;
      }
    } catch (e) {
      showModernError(context, 'Impossible d\'initialiser la reconnaissance vocale. Merci de réessayer.');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult, BuildContext context) async {
    try {
      await _speechToText.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    } catch (e) {
      showModernError(context, 'Erreur lors de l\'écoute. Merci de réessayer.');
    }
  }

  void stopListening() {
    _speechToText.stop();
  }

  bool isListening() {
    return _speechToText.isListening;
  }

  Future<void> stopListeningWithFeedback(BuildContext context) async {
    try {
      await _speechToText.stop();
      showModernError(context, 'Écoute arrêtée.');
    } catch (e) {
      showModernError(context, 'Impossible d\'arrêter l\'écoute.');
    }
  }
}