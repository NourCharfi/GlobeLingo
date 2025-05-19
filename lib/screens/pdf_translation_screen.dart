import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import '../services/file_service.dart';
import '../widgets/language_dropdown.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import '../widgets/modern_error_alert.dart';
import '../widgets/custom_convex_nav_bar.dart'; // Import du CustomConvexNavBar

class PDFTranslationScreen extends StatefulWidget {
  @override
  _PDFTranslationScreenState createState() => _PDFTranslationScreenState();
}

class _PDFTranslationScreenState extends State<PDFTranslationScreen> {
  String _sourceLanguage = 'en';
  String _targetLanguage = 'fr';
  final FileService _fileService = FileService();
  String _translatedText = "";
  String _selectedFileName = ""; // Nom du fichier sélectionné
  String? _translatedFilePath; // Chemin du fichier PDF traduit
  bool _isTranslating = false;
  String? _userErrorMessage; // Pour afficher une erreur utilisateur sous forme d'alerte

  Future<void> _processPDF(String filePath) async {
    if (filePath.isEmpty) {
      showModernError(context, 'Veuillez sélectionner un fichier PDF avant de lancer la traduction.');
      return;
    }
    if (!filePath.toLowerCase().endsWith('.pdf')) {
      showModernError(context, 'Le fichier choisi n\'est pas au format PDF. Merci de sélectionner un fichier PDF valide.');
      return;
    }
    setState(() {
      _selectedFileName = filePath.split('/').last;
      _translatedText = "";
      _userErrorMessage = null;
    });
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        showModernError(context, 'Le fichier PDF n\'est plus disponible ou a été déplacé. Merci de le sélectionner à nouveau.');
        return;
      }
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        extractedText += PdfTextExtractor(document).extractText(startPageIndex: i) + '\n';
      }
      document.dispose();
      if (extractedText.trim().isEmpty) {
        showModernError(context, 'Aucun texte détecté dans ce PDF. Essayez un autre document.');
        return;
      }
      await _translateText(extractedText);
    } catch (e) {
      setState(() {
        _userErrorMessage = "Impossible de lire ce PDF. Merci de vérifier le fichier ou d\'en choisir un autre.";
      });
      showModernError(context, 'Impossible de lire ce PDF. Merci de vérifier le fichier ou d\'en choisir un autre.');
    }
  }

  Future<void> _translateText(String text) async {
    setState(() { _isTranslating = true; _userErrorMessage = null; });
    try {
      final OnDeviceTranslator translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _sourceLanguage),
        targetLanguage: TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == _targetLanguage),
      );
      final translation = await translator.translateText(text);
      setState(() {
        _translatedText = translation;
      });
      translator.close();
    } catch (e) {
      setState(() {
        _userErrorMessage = "Traduction impossible. Veuillez réessayer plus tard ou choisir un autre PDF.";
        _translatedText = "";
      });
      showModernError(context, 'Traduction impossible. Veuillez réessayer plus tard ou choisir un autre PDF.');
    } finally {
      setState(() { _isTranslating = false; });
    }
  }

  Future<void> _pickPDF() async {
    final pdfPath = await _fileService.pickPDF();
    if (pdfPath != null) {
      await _processPDF(pdfPath);
    }
  }

  Future<void> _generateTranslatedPDF() async {
    if (_translatedText.isEmpty) {
      showModernError(context, 'Aucun texte traduit à enregistrer.');
      return;
    }
    try {
      final PdfDocument pdf = PdfDocument();
      // Utilisation de rootBundle pour charger la police depuis les assets Flutter
      final fontData = (await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')).buffer.asUint8List();
      final PdfFont font = PdfTrueTypeFont(fontData, 12);
      PdfPage page = pdf.pages.add();
      double y = 0;
      final paragraphs = _translatedText.split(RegExp(r'\n{2,}|\r\n{2,}'));
      for (final para in paragraphs) {
        final PdfTextElement textElement = PdfTextElement(text: para.trim() + "\n\n", font: font);
        final result = textElement.draw(
          page: page,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, page.getClientSize().height - y),
        );
        if (result != null) {
          page = result.page;
          y = result.bounds.bottom;
        }
      }
      String baseName = _selectedFileName.replaceAll('.pdf', '').replaceAll('.PDF', '');
      final output = await _fileService.savePDF(pdf, originalFileName: baseName + '_traduit.pdf');
      pdf.dispose();
      setState(() {
        _translatedFilePath = output;
      });
      // Succès : on peut garder le SnackBar ou utiliser un dialog moderne si tu veux
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF traduit enregistré : $output')),
      );
    } catch (e) {
      showModernError(context, 'Erreur lors de la génération du PDF traduit : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Traduction de PDF'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
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
                  Text(
                    'Fichier sélectionné : $_selectedFileName',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Color(0xFF1976D2),
                          ),
                          onPressed: () async {
                            await _pickPDF();
                          },
                          child: Text('Choisir un fichier PDF', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Color(0xFF2196F3),
                          ),
                          onPressed: (_selectedFileName.isEmpty || _isTranslating)
                              ? null
                              : () async {
                                  if (_selectedFileName.isEmpty) {
                                    showModernError(context, 'Veuillez d\'abord choisir un fichier PDF.');
                                    return;
                                  }
                                  if (!_selectedFileName.toLowerCase().endsWith('.pdf')) {
                                    showModernError(context, 'Le fichier choisi n\'est pas au format PDF. Merci de sélectionner un fichier PDF valide.');
                                    return;
                                  }
                                  await _processPDF(_selectedFileName);
                                },
                          child: Text('Traduire le fichier', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_isTranslating)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 36, height: 36,
                            child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF1976D2)),
                          ),
                          SizedBox(height: 8),
                          Text('Traduction en cours...', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (!_isTranslating && _translatedText.isNotEmpty)
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 400, // Largeur minimale augmentée
                          maxWidth: 600, // Largeur maximale augmentée
                          minHeight: 80,
                          maxHeight: 300,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Texte traduit :',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                    )),
                                SizedBox(height: 8),
                                Container(
                                  height: 200, // hauteur fixe pour permettre le scroll
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
                      ),
                    ),
                  if (_userErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          _userErrorMessage!,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  if (!_isTranslating && _translatedText.isNotEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Color(0xFF42A5F5),
                      ),
                      onPressed: () async {
                        await _generateTranslatedPDF();
                      },
                      child: Text('Enregistrer le PDF traduit', style: TextStyle(fontSize: 15)),
                    ),
                  if (_translatedFilePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          await OpenFile.open(_translatedFilePath!);
                        },
                        child: Text(
                          _translatedFilePath!.split('/').last,
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      bottomNavigationBar: CustomConvexNavBar(
        selectedIndex: 2, // Index de la page PDF
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