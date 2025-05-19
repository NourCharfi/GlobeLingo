import 'package:app_project_mlkit/screens/quiz_screen.dart';
import 'package:app_project_mlkit/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme_provider.dart';
import '../widgets/custom_convex_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: Text('Localisation non disponible.')));
    }
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(loc.homeTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
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
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          children: [
            _buildMenuItem(
              context,
              icon: Icons.text_fields,
              label: loc.ocr,
              onTap: () {
                Navigator.pushNamed(context, '/ocr');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.mic,
              label: loc.voiceTranslation,
              onTap: () {
                Navigator.pushNamed(context, '/voice');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.picture_as_pdf,
              label: loc.pdfTranslation,
              onTap: () {
                Navigator.pushNamed(context, '/pdf');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.camera_alt,
              label: loc.objectDetection,
              onTap: () {
                Navigator.pushNamed(context, '/object');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.translate,
              label: loc.simpleTranslation,
              onTap: () {
                Navigator.pushNamed(context, '/simple');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.book,
              label: loc.dictionary,
              onTap: () {
                Navigator.pushNamed(context, '/dictionary');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        color: Colors.white.withOpacity(0.95),
        shadowColor: Color(0xFF1976D2).withOpacity(0.2),
        child: Container(
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(18),
                child: Icon(icon, size: 44.0, color: Colors.white),
              ),
              SizedBox(height: 16.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TranslationScreen extends StatelessWidget {
  final String translatedText;

  TranslationScreen({required this.translatedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Traduction'),
      ),
      body: Center(
        child: Text(
          translatedText,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

class HomeRootScreen extends StatefulWidget {
  @override
  State<HomeRootScreen> createState() => _HomeRootScreenState();
}

class _HomeRootScreenState extends State<HomeRootScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [HomeScreen(), QuizScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomConvexNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}