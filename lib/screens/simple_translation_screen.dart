import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/modern_error_alert.dart';
import '../services/text_to_speech_service.dart';
import '../widgets/custom_convex_nav_bar.dart';

class SimpleTranslationScreen extends StatefulWidget {
  @override
  _SimpleTranslationScreenState createState() => _SimpleTranslationScreenState();
}

class _SimpleTranslationScreenState extends State<SimpleTranslationScreen> {
  String _sourceLanguage = 'en';
  String _targetLanguage = 'fr';
  String _inputText = '';
  String _translatedText = '';
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  bool _isSpeaking = false;
  int _selectedIndex = 0;

  Future<void> _translateText() async {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return;
    }
    if (_inputText.trim().isEmpty) {
      showModernError(context, loc.inputTextRequired);
      return;
    }
    try {
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _sourceLanguage),
        targetLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _targetLanguage),
      );
      final translation = await translator.translateText(_inputText);
      setState(() {
        _translatedText = translation;
      });
      translator.close();
    } catch (e) {
      showModernError(context, loc.translationImpossible);
    }
  }

  Future<void> _speakText(String text) async {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return;
    }
    if (text.isEmpty) {
      showModernError(context, loc.noTextToRead);
      return;
    }
    setState(() { _isSpeaking = true; });
    try {
      await _textToSpeechService.speak(text, _targetLanguage, context);
    } catch (e) {
      showModernError(context, loc.cannotReadTranslation);
    } finally {
      setState(() { _isSpeaking = false; });
    }
  }

  void _stopSpeaking() {
    _textToSpeechService.stop();
    setState(() { _isSpeaking = false; });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/quiz');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(loc?.simpleTranslation ?? 'Traduction Simple'),
        centerTitle: true,
      ),
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
                        _quickNavIcon(context, Icons.text_fields, loc?.ocr ?? 'OCR', '/ocr'),
                        _quickNavIcon(context, Icons.mic, loc?.voiceTranslation ?? 'Vocale', '/voice'),
                        _quickNavIcon(context, Icons.picture_as_pdf, loc?.pdfTranslation ?? 'PDF', '/pdf'),
                        _quickNavIcon(context, Icons.camera_alt, loc?.objectDetection ?? 'Objets', '/object'),
                        _quickNavIcon(context, Icons.book, loc?.dictionary ?? 'Dico', '/dictionary'),
                      ],
                    ),
                  ),
                  Card(
                    elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 4,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF23243A)
                        : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: LanguageDropdown(
                              selectedLanguage: _sourceLanguage,
                              onLanguageChanged: (languageCode) async {
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
                              onLanguageChanged: (languageCode) async {
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
                  Text(
                    loc?.enterTextToTranslate != null
                      ? loc!.enterTextToTranslate + 'Entrez le texte à traduire :'
                      : 'Entrez le texte à traduire :',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF23243A)
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      labelText: loc?.enterTextToTranslate ?? 'Entrez le texte à traduire',
                      hintText: 'Saisir le texte...', // Ajout du placeholder
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      prefixIcon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    onChanged: (value) async {
                      setState(() {
                        _inputText = value;
                      });
                      if (value.trim().isEmpty) {
                        setState(() { _translatedText = ''; });
                      } else {
                        await _translateText();
                      }
                    },
                    minLines: 1,
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  if (_isSpeaking)
                    Center(child: CircularProgressIndicator()),
                  if (_translatedText.isNotEmpty)
                    Card(
                      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF23243A)
                          : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  loc?.translatedText != null
                                    ? loc!.translatedText + ' Texte traduit :'
                                    : 'Texte traduit :',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue[200]
                                        : Color(0xFF1976D2),
                                  ),
                                ),
                                if (_translatedText.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.volume_up, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Color(0xFF1976D2), size: 26),
                                    tooltip: loc?.listenTranslation ?? 'Écouter la traduction',
                                    onPressed: _isSpeaking ? null : () async {
                                      setState(() { _isSpeaking = true; });
                                      await _textToSpeechService.speak(_translatedText, _targetLanguage, context);
                                      setState(() { _isSpeaking = false; });
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 80,
                                maxHeight: 200,
                              ),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[900]?.withOpacity(0.2)
                                    : Color(0xFFe3f2fd),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SelectableText(
                                    _translatedText.isEmpty
                                      ? 'La traduction s’affichera ici.' // Placeholder pour la box de texte traduit
                                      : _translatedText,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
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
        selectedIndex: 2, // Index de la page Traduction simple
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/quiz');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
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