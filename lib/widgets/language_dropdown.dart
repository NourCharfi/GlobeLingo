import 'package:flutter/material.dart';
import '../models/translation.dart';

typedef LanguageChangedCallback = void Function(String languageCode);

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final LanguageChangedCallback onLanguageChanged;

  LanguageDropdown({
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languages = Translation.getSupportedLanguages();

    return DropdownButton<String>(
      value: selectedLanguage,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onLanguageChanged(newValue);
        }
      },
      items: languages.map<DropdownMenuItem<String>>((Translation language) {
        return DropdownMenuItem<String>(
          value: language.languageCode,
          child: Text(language.displayName),
        );
      }).toList(),
    );
  }
}