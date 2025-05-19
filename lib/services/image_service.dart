import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        throw Exception('Aucune image sélectionnée.');
      }
      return pickedFile.path;
    } catch (e) {
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<String?> captureImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        throw Exception('Aucune image capturée.');
      }
      return pickedFile.path;
    } catch (e) {
      print('Erreur lors de la capture de l\'image : $e');
      return null;
    }
  }
}