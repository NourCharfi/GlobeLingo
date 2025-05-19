import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../services/image_service.dart';
import '../widgets/language_dropdown.dart';
import '../services/text_to_speech_service.dart';
import '../widgets/modern_error_alert.dart';
import '../widgets/custom_convex_nav_bar.dart';

class OCRTranslationScreen extends StatefulWidget {
  @override
  _OCRTranslationScreenState createState() => _OCRTranslationScreenState();
}

class _OCRTranslationScreenState extends State<OCRTranslationScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImageService _imageService = ImageService();
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  String _recognizedText = "";
  String _translatedText = "";
  String _sourceLanguage = 'en';
  String _targetLanguage = 'fr';
  bool _isSpeaking = false;
  bool _isTranslating = false;

  void _showError(String message) {
    showModernError(context, message);
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        _showError('Aucun texte détecté dans l\'image.');
        return;
      }

      setState(() {
        _recognizedText = recognizedText.text;
      });

      await _translateText(_recognizedText);
    } catch (e) {
      _showError('Impossible d\'extraire le texte de l\'image. Merci de réessayer avec une image différente.');
    }
  }

  Future<void> _translateText(String text) async {
    setState(() {
      _isTranslating = true;
    });
    try {
      final sourceLang = TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == _sourceLanguage,
        orElse: () => TranslateLanguage.english,
      );
      final targetLang = TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == _targetLanguage,
        orElse: () => TranslateLanguage.french,
      );

      final translator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
      final translation = await translator.translateText(text);
      setState(() {
        _translatedText = translation.isNotEmpty ? translation : "Aucune traduction disponible.";
      });
      translator.close();
    } catch (e) {
      setState(() {
        _translatedText = "Traduction impossible. Merci de réessayer plus tard.";
      });
      _showError('Traduction impossible. Merci de réessayer plus tard.');
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _captureImageFromCamera() async {
    final imagePath = await _imageService.captureImageFromCamera();
    if (imagePath != null) {
      await _processImage(imagePath);
    } else {
      _showError('Aucune image capturée.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await _imageService.pickImage();
    if (imagePath != null) {
      await _processImage(imagePath);
    } else {
      _showError('Aucune image sélectionnée.');
    }
  }

  Future<void> _speakText(String text) async {
    setState(() { _isSpeaking = true; });
    try {
      await _textToSpeechService.speak(text, _targetLanguage, context);
    } catch (e) {
      _showError('Impossible de lire le texte traduit.');
    } finally {
      setState(() { _isSpeaking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('OCR'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Color(0xFF1976D2),
                        ),
                        onPressed: () async {
                          await _captureImageFromCamera();
                        },
                        child: Text('Capturer une image', style: TextStyle(fontSize: 15)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Color(0xFF2196F3),
                        ),
                        onPressed: () async {
                          await _pickImageFromGallery();
                        },
                        child: Text('Choisir depuis la galerie', style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Texte reconnu :',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  )),
                              SizedBox(height: 8),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                  maxHeight: MediaQuery.of(context).size.height * 0.25,
                                  minWidth: double.infinity,
                                ),
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SelectableText(
                                      _recognizedText.isEmpty ? 'Aucun texte détecté.' : _recognizedText,
                                      style: TextStyle(
                                        fontSize: 15.0,
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
                      SizedBox(height: 18),
                      if (_isTranslating)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3)),
                              SizedBox(width: 12),
                              Text("Traduction en cours...", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
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
                                Row(
                                  children: [
                                    Text('Texte traduit :',
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1976D2),
                                        )),
                                    if (!_isTranslating && _translatedText.isNotEmpty)
                                      IconButton(
                                        icon: Icon(Icons.volume_up, color: Color(0xFF1976D2), size: 26),
                                        tooltip: 'Écouter la traduction',
                                        onPressed: _isSpeaking ? null : () async {
                                          await _speakText(_translatedText);
                                        },
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Container(
                                  constraints: BoxConstraints(
                                    minHeight: 80,
                                    maxHeight: MediaQuery.of(context).size.height * 0.25,
                                    minWidth: double.infinity,
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SelectableText(
                                        _translatedText.isEmpty ? 'Aucune traduction disponible.' : _translatedText,
                                        style: TextStyle(
                                          fontSize: 15.0,
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomConvexNavBar(
        selectedIndex: 0, // Index de la page OCR (à adapter si tu veux un autre index)
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

  @override
  void dispose() {
    _textRecognizer.close();
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