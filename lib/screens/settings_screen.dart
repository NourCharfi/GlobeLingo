import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: Text('Localisation non disponible.')));
    }
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(loc.settings),
        centerTitle: true,
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thème', style: TextStyle(fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: Text(themeProvider.themeMode == ThemeMode.dark ? 'Mode sombre' : 'Mode clair'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  themeProvider.toggleTheme();
                },
              ),
              SizedBox(height: 24),
              Text('Langue de l\'application', style: TextStyle(fontWeight: FontWeight.bold)),
              // Ici, tu peux ajouter un DropdownButton pour changer la langue de l'app
              // (nécessite une gestion de locale dans le provider ou le MaterialApp)
              // Pour l'instant, on affiche juste l'info
              Text('La langue suit celle du téléphone.'),
            ],
          ),
        ),
      ),
    );
  }
}
