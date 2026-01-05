# GlobeLingo

Tagline : Apprenez, traduisez et communiquez facilement — partout dans le monde.
<img width="405" height="105" alt="image" src="https://github.com/user-attachments/assets/64c90faf-1b46-494b-a44e-ccbb634bfe99" />

---

## Présentation
GlobeLingo est une application Flutter multiplateforme pensée pour les voyageurs, les étudiants et les professionnels qui ont besoin de surmonter rapidement les barrières linguistiques. Elle combine traduction multicanal, reconnaissance vocale, OCR, quiz linguistiques et dictionnaire intégré — le tout enrichi par des modèles d'IA et une stack moderne (Google ML Kit, Firebase).

Public cible : voyageurs, expatriés, enseignants, étudiants en langues, entreprises souhaitant des solutions d'accessibilité linguistique.

---

## Proposition de valeur
GlobeLingo transforme des moments stressants (commander, demander son chemin, gérer une urgence) en interactions simples et sûres en fournissant :
- Traductions fiables et contextuelles sur texte, image, voix et documents,
- Outils d’apprentissage courts et engageants pour progresser rapidement,
- Expérience accessible et utilisable hors‑ligne pour la confidentialité et la continuité.

---

## Fonctionnalités principales
- Traduction multicanal :
  - Texte saisi, voix (reconnaissance + synthèse), images (OCR) et documents PDF.
- Quiz linguistique :
  - Quiz adaptatifs pour tester et renforcer l’apprentissage.
- Dictionnaire intégré :
  - Recherche rapide de définitions et traductions de mots.
- Mode hors‑ligne :
  - Accès au phrasebook et aux fonctions essentielles sans connexion.
- Personnalisation & UX :
  - Thème clair/sombre, réglages utilisateur, navigation fluide.
- Historique et favoris :
  - Sauvegarde des traductions et expressions utiles.
- Accessibilité :
  - Gestion des paramètres d'accessibilité et support vocal.

---

## Use Cases (Cas d'usage) — définition & technologies
- Traduction de texte  
  - Technologies : Google ML Kit, Flutter  
  - Description : Traduction instantanée du texte saisi dans l’app.

- Traduction vocale  
  - Technologies : Google ML Kit, speech_to_text, flutter_tts  
  - Description : Reconnaissance de la parole, transcription, traduction et lecture vocale du résultat.

- Traduction d’images (OCR)  
  - Technologies : Google ML Kit OCR, Flutter  
  - Description : Extraction du texte depuis une photo ou via la caméra, puis traduction.

- Traduction de PDF  
  - Technologies : Flutter, file_picker, Google ML Kit  
  - Description : Extraction et traduction du texte contenu dans des PDF importés.

- Quiz & parcours d’apprentissage  
  - Technologies : Flutter, Provider  
  - Description : Exercices et quiz pour réviser le vocabulaire et la grammaire.

- Consultation du dictionnaire  
  - Technologies : Flutter, Provider  
  - Description : Recherche rapide pour enrichir le vocabulaire et consulter prononciations.

- Personnalisation de l’expérience  
  - Technologies : Flutter, Provider, Firebase (pour profils et préférences)  
  - Description : Thèmes, langues d’interface, réglages accessibles, profils utilisateurs.

---

## Avantages pour l'utilisateur (bénéfices)
- Communiquer rapidement et en confiance dans des situations réelles.
- Gagner du temps avec des traductions contextuelles et multicanales.
- Progresser quotidiennement grâce à des micro-leçons et quiz.
- Utiliser l’app hors‑ligne pour la confidentialité et en zone sans réseau.
- Bénéficier d’une expérience inclusive grâce à la synthèse vocale et à l’accessibilité.

---

## Technologie & architecture
- Langage principal : Dart (Flutter) — application cross‑platform (iOS, Android, Web/PWA).
- Modules natifs/performance : C++ (traitement performant) — orchestrés via CMake.
- IA & ML : Google ML Kit (OCR, traduction, reconnaissance vocale).
- Backend & données : Firebase (auth, Firestore, analytics, storage), local storage pour mode hors‑ligne.
- Packages notables : speech_to_text, flutter_tts, file_picker, provider, etc.

---

