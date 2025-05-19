import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/image_service.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/modern_error_alert.dart';
import '../widgets/custom_convex_nav_bar.dart'; // Import du CustomConvexNavBar

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    ),
  );
  final ImageService _imageService = ImageService();
  String _detectedObjectsInitial = "";
  String _detectedObjectsTranslated = "";
  String _selectedLanguage = 'en';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'fr';
  bool _isTranslatingObjects = false;

  void _showError(String message) {
    showModernError(context, message);
  }

  Future<void> _processImage(String imagePath) async {
    try {
      setState(() { _isTranslatingObjects = true; });
      final inputImage = InputImage.fromFilePath(imagePath);
      final objects = await _objectDetector.processImage(inputImage);

      if (objects.isEmpty) {
        setState(() { _isTranslatingObjects = false; });
        _showError('Aucun objet détecté dans l\'image.');
        return;
      }

      // Affichage des objets dans la langue initiale (labels bruts)
      String objetsInitiaux = objects.map((object) => object.labels.map((label) => label.text).join(", ")).join("\n");
      String objetsTraduits = objetsInitiaux;
      if (_targetLanguage != _sourceLanguage && objetsInitiaux.isNotEmpty) {
        final labels = objetsInitiaux.split(RegExp(r'[\n,]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
        objetsTraduits = await _translateLabels(labels, _sourceLanguage, _targetLanguage);
      }
      setState(() {
        _detectedObjectsInitial = objetsInitiaux;
        _detectedObjectsTranslated = objetsTraduits;
        _isTranslatingObjects = false;
      });
    } catch (e) {
      setState(() { _isTranslatingObjects = false; });
      _showError('Impossible de détecter les objets sur cette image. Merci de réessayer avec une autre image.');
    }
  }

  Future<void> _captureImageFromCamera() async {
    final imagePath = await _imageService.captureImageFromCamera();
    if (imagePath != null) {
      await _processImage(imagePath);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await _imageService.pickImage();
    if (imagePath != null) {
      await _processImage(imagePath);
    }
  }

  Future<String> _getWikipediaSummary(String label, String lang) async {
    final url = 'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(label)}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['extract'] != null && data['extract'].toString().trim().isNotEmpty) {
          return data['extract'];
        }
      }
    } catch (_) {}
    return '';
  }

  // Ajout de la fonction utilitaire asynchrone :
  Future<String> _translateLabels(List<String> labels, String sourceLang, String targetLang) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == sourceLang, orElse: () => TranslateLanguage.english),
      targetLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == targetLang, orElse: () => TranslateLanguage.french),
    );
    List<String> translated = [];
    for (final label in labels) {
      try {
        final t = await translator.translateText(label);
        final summary = await _getWikipediaSummary(t, targetLang);
        if (summary.isNotEmpty) {
          translated.add('$t\nRésumé : $summary');
        } else {
          translated.add(t);
        }
      } catch (_) {
        translated.add(label); // fallback si erreur
      }
    }
    translator.close();
    return translated.join("\n\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permet au fond de passer sous le navbar
      appBar: AppBar(
        title: Text('Reconnaissance d\'objets'),
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
                  // Affichage des box objets l’une sous l’autre (vertical, responsive, sans overflow)
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
                              Text('Objets (${_sourceLanguage}) :',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  )),
                              SizedBox(height: 8),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                  maxHeight: MediaQuery.of(context).size.height * 0.22,
                                  minWidth: double.infinity,
                                ),
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SelectableText(
                                      _detectedObjectsInitial.isEmpty ? 'Aucun objet détecté.' : _detectedObjectsInitial,
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
                      SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Objets (${_targetLanguage}) :',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  )),
                              SizedBox(height: 8),
                              if (_isTranslatingObjects)
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1976D2))),
                                      SizedBox(width: 12),
                                      Text('Traduction des objets en cours...', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              if (!_isTranslatingObjects)
                                Container(
                                  constraints: BoxConstraints(
                                    minHeight: 80,
                                    maxHeight: MediaQuery.of(context).size.height * 0.22,
                                    minWidth: double.infinity,
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SelectableText(
                                        _detectedObjectsTranslated.isEmpty ? 'Aucun objet traduit.' : _detectedObjectsTranslated,
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
        selectedIndex: 0, // Index de la page Objets (à adapter si tu veux un autre index)
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
    _objectDetector.close();
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