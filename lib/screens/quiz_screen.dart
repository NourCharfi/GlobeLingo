import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../models/translation.dart';
import '../widgets/custom_convex_nav_bar.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Liste des catégories Trivia API (exemples)
  final Map<String, String> _categories = {
    'general_knowledge': 'Culture générale',
    'arts_and_literature': 'Arts et littérature',
    'film_and_tv': 'Films et TV',
    'food_and_drink': 'Nourriture et boissons',
    'geography': 'Géographie',
    'history': 'Histoire',
    'music': 'Musique',
    'science': 'Sciences',
    'society_and_culture': 'Société et culture',
    'sport_and_leisure': 'Sport et loisirs',
  };
  String _selectedLang = 'fr';
  String _selectedCategory = 'general_knowledge';
  int _numQuestions = 5;
  int _current = 0;
  bool _showResult = false;
  List<Map<String, dynamic>> _questions = [];
  List<int?> _userAnswers = [];
  bool _isLoading = false;
  bool _isTranslatingQuestions = false;
  String? _error;
  bool _quizStarted = false;
  bool _autoTranslationUsed = false;

  // Liste des langues supportées par MLKit (toutes les langues possibles)
  late final List<Translation> _mlkitLanguages;

  @override
  void initState() {
    super.initState();
    _mlkitLanguages = Translation.getSupportedLanguages();
    if (!_mlkitLanguages.any((l) => l.languageCode == _selectedLang)) {
      _selectedLang = _mlkitLanguages.first.languageCode;
    }
  }

  // Détecte si une chaîne est dans la langue cible (simple heuristique)
  bool _isLikelyInTargetLang(String text, String langCode) {
    // Pour l'anglais/français/espagnol/allemand/italien/portugais, on peut tester la présence de caractères accentués ou mots courants
    // Pour un vrai projet, utiliser un package de détection de langue
    if (langCode == 'fr') return RegExp(r'[éèàùçôêâîûëïüœ]').hasMatch(text) || text.contains('le ');
    if (langCode == 'en') return RegExp(r'[a-zA-Z]').hasMatch(text) && !RegExp(r'[éèàùçôêâîûëïüœ]').hasMatch(text);
    if (langCode == 'es') return RegExp(r'[ñáéíóúü]').hasMatch(text) || text.contains('el ');
    if (langCode == 'de') return RegExp(r'[äöüß]').hasMatch(text) || text.contains('der ');
    if (langCode == 'it') return RegExp(r'[àèéìòù]').hasMatch(text) || text.contains('il ');
    if (langCode == 'pt') return RegExp(r'[ãõáâêéíóôúç]').hasMatch(text) || text.contains('o ');
    return true; // fallback : suppose ok
  }

  Future<void> _translateQuestionsIfNeeded() async {
    setState(() { _isTranslatingQuestions = true; _autoTranslationUsed = false; });
    final targetLang = _selectedLang;
    bool translationNeeded = false;
    List<Map<String, dynamic>> translatedQuestions = [];
    for (var q in _questions) {
      final questionText = q['question'] as String;
      final options = List<String>.from(q['options']);
      // On traduit toujours si la langue cible n'est pas l'anglais
      if (targetLang != 'en') {
        translationNeeded = true;
        final translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.english,
          targetLanguage: TranslateLanguage.values.firstWhere((l) => l.bcpCode == targetLang, orElse: () => TranslateLanguage.french),
        );
        final translatedQuestion = await translator.translateText(questionText);
        final translatedOptions = <String>[];
        for (final opt in options) {
          translatedOptions.add(await translator.translateText(opt));
        }
        // Traduire aussi la bonne réponse pour retrouver l'index
        final translatedCorrect = await translator.translateText(q['correctAnswer']);
        int correctIndex = translatedOptions.indexOf(translatedCorrect);
        if (correctIndex == -1) correctIndex = 0; // fallback si la traduction ne matche pas
        await translator.close();
        translatedQuestions.add({
          ...q,
          'question': translatedQuestion,
          'options': translatedOptions,
          'answer': correctIndex,
        });
      } else {
        translatedQuestions.add(q);
      }
    }
    if (translationNeeded) {
      setState(() {
        _questions = translatedQuestions;
        _autoTranslationUsed = true;
      });
    }
    setState(() { _isTranslatingQuestions = false; });
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isTranslatingQuestions = false;
      _autoTranslationUsed = false;
    });
    try {
      final lang = _selectedLang;
      final category = _selectedCategory;
      final url = Uri.parse('https://the-trivia-api.com/api/questions?limit=$_numQuestions&region=FR&difficulty=easy&languages=$lang&categories=$category');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _questions = data.map((q) => {
            'question': q['question'],
            'options': List<String>.from([q['correctAnswer'], ...q['incorrectAnswers']])..shuffle(),
            'answer': null, // sera déterminé ci-dessous
            'correctAnswer': q['correctAnswer'],
          }).toList();
          // Déterminer l'index de la bonne réponse dans chaque question
          for (var q in _questions) {
            q['answer'] = q['options'].indexOf(q['correctAnswer']);
          }
          _userAnswers = List.filled(_questions.length, null);
          _current = 0;
          _showResult = false;
        });
        // Traduction automatique si besoin
        await _translateQuestionsIfNeeded();
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des questions.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau ou format inattendu.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLangChanged(String? lang) {
    if (lang != null) {
      setState(() {
        _selectedLang = lang;
      });
    }
  }

  void _onCategoryChanged(String? cat) {
    if (cat != null) {
      setState(() {
        _selectedCategory = cat;
      });
    }
  }

  void _onNumQuestionsChanged(double value) {
    setState(() {
      _numQuestions = value.toInt();
    });
  }

  void _onAnswerSelected(int idx) {
    setState(() {
      _userAnswers[_current] = idx;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() {
        _current--;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _quizStarted = false;
      _questions = [];
      _userAnswers = [];
      _showResult = false;
      _current = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isTranslatingQuestions) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text('Quiz éducatif')),
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(_isTranslatingQuestions ? 'Traduction automatique des questions...' : 'Chargement du quiz...'),
          ],
        )),
      );
    }
    if (_error != null) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text('Quiz éducatif')),
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      );
    }
    if (!_quizStarted) {
      // Page d'accueil du quiz
      return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text('Quiz éducatif')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Langue du quiz', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLang,
                items: _mlkitLanguages.map((lang) => DropdownMenuItem<String>(
                  value: lang.languageCode,
                  child: Text(lang.displayName),
                )).toList(),
                onChanged: _onLangChanged,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 20),
              Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.entries.map((entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                )).toList(),
                onChanged: _onCategoryChanged,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              SizedBox(height: 20),
              Text('Nombre de questions', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _numQuestions.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                label: '$_numQuestions',
                onChanged: _onNumQuestionsChanged,
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() { _quizStarted = true; });
                    await _fetchQuestions();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Lancer le quiz', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text('Quiz éducatif')),
        body: Center(child: Text('Aucune question disponible.')),
      );
    }
    // Affichage du résultat si demandé
    if (_showResult) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(title: Text('Quiz éducatif')),
        body: Container(
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: _buildResult(_questions),
            ),
          ),
        ),
        bottomNavigationBar: CustomConvexNavBar(
          selectedIndex: 1, // Index de la page Quiz
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                // Déjà sur Quiz
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/settings');
                break;
            }
          },
        ),
      );
    }
    final questions = _questions;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Quiz éducatif'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_autoTranslationUsed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '⚠️ Les questions ont été traduites automatiquement car la langue réelle ne correspondait pas à la langue choisie.',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Text('Question ${_current + 1} / $_numQuestions', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Langue : ${_mlkitLanguages.firstWhere((l) => l.languageCode == _selectedLang, orElse: () => Translation(languageCode: _selectedLang, displayName: _selectedLang)).displayName}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(questions[_current]['question'], style: TextStyle(fontSize: 17)),
                          SizedBox(height: 16),
                          ...List.generate(questions[_current]['options'].length, (idx) {
                            return RadioListTile<int>(
                              value: idx,
                              groupValue: _userAnswers[_current],
                              onChanged: (val) => _onAnswerSelected(idx),
                              title: Text(questions[_current]['options'][idx]),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _current > 0 ? _prev : null,
                        child: Text('Précédent'),
                      ),
                      ElevatedButton(
                        onPressed: _userAnswers[_current] != null ? _next : null,
                        child: Text(_current == _numQuestions - 1 ? 'Terminer' : 'Suivant'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomConvexNavBar(
        selectedIndex: 1, // Index de la page Quiz
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Déjà sur Quiz
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildResult(List<Map<String, dynamic>> questions) {
    int score = 0;
    for (int i = 0; i < _numQuestions; i++) {
      if (_userAnswers[i] == questions[i]['answer']) score++;
    }
    double ratio = score / _numQuestions;
    String emoji;
    if (ratio < 0.4) {
      emoji = '😢';
    } else if (ratio < 0.8) {
      emoji = '🙂';
    } else {
      emoji = '🎉';
    }
    Color progressColor;
    if (ratio < 0.4) {
      progressColor = Colors.redAccent;
    } else if (ratio < 0.8) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.green;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Résultat du quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: Duration(seconds: 1),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: progressColor)),
                      Text(emoji, style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          Text('Score : $score / $_numQuestions', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _numQuestions,
            itemBuilder: (context, idx) {
              final q = questions[idx];
              final user = _userAnswers[idx];
              final correct = q['answer'];
              final isCorrect = user == correct;
              return Card(
                color: isCorrect ? Colors.green[50] : Colors.red[50],
                child: ListTile(
                  title: Text(q['question'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre réponse : ${user != null && user < q['options'].length ? q['options'][user] : 'Aucune'}',
                          style: TextStyle(color: isCorrect ? Colors.green : Colors.red)),
                      if (!isCorrect)
                        Text('Bonne réponse : ${q['options'][correct]}', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  trailing: isCorrect
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.cancel, color: Colors.red),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _resetQuiz();
                });
              },
              child: Text('Recommencer'),
            ),
          ),
        ],
      ),
    );
  }
}
