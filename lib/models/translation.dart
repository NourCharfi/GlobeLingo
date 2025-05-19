class Translation {
  final String languageCode;
  final String displayName;

  Translation({required this.languageCode, required this.displayName});

  static List<Translation> getSupportedLanguages() {
    return [
      Translation(languageCode: 'en', displayName: 'English'),
      Translation(languageCode: 'fr', displayName: 'French'),
      Translation(languageCode: 'es', displayName: 'Spanish'),
      Translation(languageCode: 'de', displayName: 'German'),
      Translation(languageCode: 'zh', displayName: 'Chinese'),
      Translation(languageCode: 'ar', displayName: 'Arabic'),
      Translation(languageCode: 'hi', displayName: 'Hindi'),
      Translation(languageCode: 'ja', displayName: 'Japanese'),
      Translation(languageCode: 'ko', displayName: 'Korean'),
      Translation(languageCode: 'ru', displayName: 'Russian'),
      Translation(languageCode: 'it', displayName: 'Italian'),
      Translation(languageCode: 'pt', displayName: 'Portuguese'),
      Translation(languageCode: 'nl', displayName: 'Dutch'),
      Translation(languageCode: 'sv', displayName: 'Swedish'),
      Translation(languageCode: 'tr', displayName: 'Turkish'),
      Translation(languageCode: 'pl', displayName: 'Polish'),
      Translation(languageCode: 'uk', displayName: 'Ukrainian'),
      Translation(languageCode: 'vi', displayName: 'Vietnamese'),
      Translation(languageCode: 'th', displayName: 'Thai'),
      Translation(languageCode: 'id', displayName: 'Indonesian'),
      Translation(languageCode: 'ms', displayName: 'Malay'),
      Translation(languageCode: 'cs', displayName: 'Czech'),
      Translation(languageCode: 'ro', displayName: 'Romanian'),
      Translation(languageCode: 'hu', displayName: 'Hungarian'),
      Translation(languageCode: 'fi', displayName: 'Finnish'),
      Translation(languageCode: 'da', displayName: 'Danish'),
      Translation(languageCode: 'no', displayName: 'Norwegian'),
    ];
  }
}