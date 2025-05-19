import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/text_to_speech_service.dart';
import '../services/speech_to_text_service.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/modern_error_alert.dart';
import '../widgets/custom_convex_nav_bar.dart';

class VoiceTranslationScreen extends StatefulWidget {
  @override
  _VoiceTranslationScreenState createState() => _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends State<VoiceTranslationScreen> {
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.french,
  );
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  String _detectedLanguage = "";
  String _translatedText = "";
  String _sourceLanguage = 'en';
  String _targetLanguage = 'fr';
  String _inputText = '';
  bool _isListening = false;
  bool _isPaused = false;
  bool _isSpeaking = false;
  bool _isTranslating = false;

  void _showError(String message) {
    showModernError(context, message);
  }

  Future<void> _identifyLanguage(String text) async {
    try {
      final language = await _languageIdentifier.identifyLanguage(text);
      setState(() {
        _detectedLanguage = language;
      });
      await _translateText(text);
    } catch (e) {
      _showError('Impossible d\'identifier la langue.');
    }
  }

  Future<void> _translateText(String text) async {
    setState(() {
      _isTranslating = true;
    });
    try {
      print('Texte à traduire : $text');
      final translation = await _translator.translateText(text);
      print('Texte traduit : $translation');
      setState(() {
        _translatedText = translation;
      });
    } catch (e) {
      _showError('Traduction impossible. Merci de réessayer plus tard.');
      setState(() {
        _translatedText = "";
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _startListening() async {
    final initialized = await _speechToTextService.initialize(context);
    if (!initialized) {
      _showError('Impossible d\'accéder au micro. Vérifiez les permissions.');
      return;
    }
    setState(() {
      _isListening = true;
      _isPaused = false;
    });
    _speechToTextService.startListening((text) async {
      setState(() {
        _inputText = text;
        _isListening = false;
        _isPaused = false;
      });
      try {
        final detectedLanguage = await _languageIdentifier.identifyLanguage(text);
        setState(() {
          _detectedLanguage = text;
        });
        await _translateText(text);
      } catch (e) {
        _showError('Erreur lors de la reconnaissance vocale.');
      }
    }, context);
  }

  Future<void> _speakText(String text) async {
    if (text.isEmpty) {
      _showError('Aucun texte à lire.');
      return;
    }
    setState(() { _isSpeaking = true; });
    try {
      await _textToSpeechService.speak(text, _targetLanguage, context);
    } catch (e) {
      _showError('Impossible de lire le texte traduit.');
    } finally {
      setState(() { _isSpeaking = false; });
    }
  }

  void _stopSpeaking() {
    _textToSpeechService.stop();
    setState(() { _isSpeaking = false; });
  }

  Future<void> _translateAndSpeak() async {
    try {
      final OnDeviceTranslator translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _sourceLanguage),
        targetLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _targetLanguage),
      );
      final translation = await translator.translateText(_inputText);
      await _textToSpeechService.speak(translation, _targetLanguage, context);
      translator.close();
    } catch (e) {
      _showError('Impossible de traduire ou lire le texte.');
    }
  }

  Future<void> _logSupportedLanguages() async {
    try {
      List<String> supportedLanguages = await _textToSpeechService.getSupportedLanguages();
      print('Langues supportées par le TTS : $supportedLanguages');
    } catch (e) {
      print('Erreur lors de la récupération des langues supportées : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _logSupportedLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Traduction vocale'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? LinearGradient(
                      colors: [Color(0xFF0D1333), Color(0xFF23243A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [Color(0xFFe3f2fd), Color(0xFF1976D2)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Barre de navigation rapide
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF181A20)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (Theme.of(context).brightness != Brightness.dark)
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickNavIcon(context, Icons.text_fields, 'Simple', '/simple'),
                        _quickNavIcon(context, Icons.mic, 'Vocale', '/voice'),
                        _quickNavIcon(context, Icons.picture_as_pdf, 'PDF', '/pdf'),
                        _quickNavIcon(context, Icons.camera_alt, 'Objets', '/object'),
                        _quickNavIcon(context, Icons.book, 'Dico', '/dictionary'),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: LanguageDropdown(
                              selectedLanguage: _sourceLanguage,
                              onLanguageChanged: (languageCode) {
                                setState(() {
                                  _sourceLanguage = languageCode;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: LanguageDropdown(
                              selectedLanguage: _targetLanguage,
                              onLanguageChanged: (languageCode) {
                                setState(() {
                                  _targetLanguage = languageCode;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Contrôle unique pour la reconnaissance vocale
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            _isListening ? Icons.stop_circle : Icons.mic,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isListening ? 'Arrêter' : 'Démarrer',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: _isListening ? Colors.redAccent : Color(0xFF42A5F5),
                          ),
                          onPressed: () async {
                            if (_isListening) {
                              _speechToTextService.stopListening();
                              setState(() { _isListening = false; });
                            } else {
                              await _startListening();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Contrôles pour la lecture du texte traduit
                  if (_translatedText.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Container()),
                        _isSpeaking
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                                ),
                                SizedBox(width: 8),
                                Text('Lecture en cours...'),
                                IconButton(
                                  icon: Icon(Icons.stop, color: Theme.of(context).colorScheme.primary),
                                  tooltip: 'Arrêter',
                                  onPressed: _isSpeaking ? _stopSpeaking : null,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary, size: 28),
                                  tooltip: 'Écouter la traduction',
                                  onPressed: () async {
                                    await _speakText(_translatedText);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.replay, color: Theme.of(context).colorScheme.primary),
                                  tooltip: 'Relancer la lecture',
                                  onPressed: () async {
                                    await _speakText(_translatedText);
                                  },
                                ),
                              ],
                            ),
                      ],
                    ),
                  SizedBox(height: 24),
                  if (_isListening || _isSpeaking)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3)),
                          SizedBox(width: 12),
                          Text("Traitement en cours...", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    )
                  else if (_translatedText.isNotEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Texte détecté :',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                )),
                            SizedBox(height: 8),
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 80,
                                maxHeight: 400,
                                minWidth: 350,
                                maxWidth: 700,
                              ),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFe3f2fd),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SelectableText(
                                    _inputText.isEmpty ? 'Aucun texte détecté.' : _inputText,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text('Texte traduit :',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                )),
                            SizedBox(height: 8),
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 80,
                                maxHeight: 400,
                                minWidth: 350,
                                maxWidth: 700,
                              ),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFe3f2fd),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SelectableText(
                                    _translatedText.isEmpty ? 'Aucune traduction.' : _translatedText,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomConvexNavBar(
        selectedIndex: 1, // Index de la page Vocale (à adapter si besoin)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Déjà sur Vocale
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _languageIdentifier.close();
    _translator.close();
    _textToSpeechService.stop();
    super.dispose();
  }

  Widget _quickNavIcon(BuildContext context, IconData icon, String tooltip, String route) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
      tooltip: tooltip,
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}