import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../widgets/custom_convex_nav_bar.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _definition = '';
  String _phonetic = '';
  String _error = '';
  bool _isLoading = false;
  String _selectedLang = 'en';
  final Map<String, String> _languages = {
    'en': 'Anglais',
    'fr': 'Français',
    'es': 'Espagnol',
    'de': 'Allemand',
    'it': 'Italien',
    'pt': 'Portugais',
    'ru': 'Russe',
    'ja': 'Japonais',
    'ko': 'Coréen',
    'ar': 'Arabe',
    'tr': 'Turc',
    'hi': 'Hindi',
    'zh': 'Chinois',
    'pl': 'Polonais',
    'nl': 'Néerlandais',
    'sv': 'Suédois',
    'uk': 'Ukrainien',
    'el': 'Grec',
    'fi': 'Finnois',
    'cs': 'Tchèque',
    'ro': 'Roumain',
    'hu': 'Hongrois',
    'id': 'Indonésien',
    'th': 'Thaï',
    'vi': 'Vietnamien',
  };

  // Langues supportées par dictionaryapi.dev
  final Set<String> _freeDictLangs = {'en', 'fr', 'es', 'de', 'it', 'pt', 'ru'};

  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  Future<void> _searchWord(String word) async {
    setState(() {
      _isLoading = true;
      _definition = '';
      _phonetic = '';
      _error = '';
    });
    try {
      bool found = false;
      String def = '';
      String phon = '';
      String wordToSearch = word;
      String detectedLang = _selectedLang;
      // Détecter la langue du mot saisi
      try {
        detectedLang = await _languageIdentifier.identifyLanguage(word);
      } catch (e) {
        // Ignore detection error, fallback to selected language
      }
      // Si la langue détectée n'est pas l'anglais, traduire le mot en anglais
      if (detectedLang != 'en') {
        try {
          final translator = OnDeviceTranslator(
            sourceLanguage: TranslateLanguage.values.firstWhere((l) => l.bcpCode == detectedLang, orElse: () => TranslateLanguage.french),
            targetLanguage: TranslateLanguage.english,
          );
          wordToSearch = await translator.translateText(word);
          await translator.close();
        } catch (e) {
          // Si la traduction échoue, on garde le mot original
        }
      }
      // Recherche la définition en anglais
      final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$wordToSearch');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final entry = data[0];
          final meanings = entry['meanings'] as List?;
          final phonetics = entry['phonetics'] as List?;
          if (meanings != null && meanings.isNotEmpty) {
            final defs = meanings[0]['definitions'] as List?;
            if (defs != null && defs.isNotEmpty) {
              def = defs[0]['definition'] ?? '';
            }
          }
          if (phonetics != null && phonetics.isNotEmpty) {
            phon = phonetics[0]['text'] ?? '';
          }
          found = def.isNotEmpty;
        }
      }
      if (found) {
        // Si la langue d'origine n'est pas l'anglais, traduire la définition dans la langue d'origine
        if (detectedLang != 'en') {
          try {
            final translator = OnDeviceTranslator(
              sourceLanguage: TranslateLanguage.english,
              targetLanguage: TranslateLanguage.values.firstWhere((l) => l.bcpCode == detectedLang, orElse: () => TranslateLanguage.french),
            );
            final translatedDef = await translator.translateText(def);
            await translator.close();
            setState(() {
              _definition = translatedDef.isNotEmpty ? translatedDef : def;
              _phonetic = phon;
            });
          } catch (e) {
            setState(() {
              _definition = def;
              _phonetic = phon;
            });
          }
        } else {
          setState(() {
            _definition = def;
            _phonetic = phon;
          });
        }
      } else {
        setState(() {
          _definition = 'Aucune définition trouvée.';
          _phonetic = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la récupération de la définition.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _detectAndSearchWord(String word) async {
    setState(() { _isLoading = true; _definition = ''; _phonetic = ''; _error = ''; });
    try {
      final detectedLang = await _languageIdentifier.identifyLanguage(word);
      if (_languages.containsKey(detectedLang)) {
        setState(() { _selectedLang = detectedLang; });
      }
    } catch (e) {
      // Ignore detection error, fallback to selected language
    }
    await _searchWord(word);
  }

  @override
  void dispose() {
    _languageIdentifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Dictionnaire'),
        // backgroundColor retiré pour laisser le thème gérer
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
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: _selectedLang,
                      decoration: InputDecoration(
                        labelText: 'Langue',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: const Color(0xFF232A3E), // bleu foncé charte
                      ),
                      items: _languages.entries.map((entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLang = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Entrez un mot',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _detectAndSearchWord(_controller.text.trim());
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _detectAndSearchWord(value.trim());
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  if (_isLoading)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3)),
                          SizedBox(width: 12),
                          Text("Recherche/traduction en cours...", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    )
                  else if (_error.isNotEmpty)
                    Text(_error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  else if (_definition.isNotEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_phonetic.isNotEmpty)
                              Text('Phonétique : $_phonetic', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Définition :', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(_definition, style: TextStyle(fontSize: 16)),
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
        selectedIndex: 2, // Index de la page Dictionnaire (à adapter si besoin)
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
