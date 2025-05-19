import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileService {
  Future<String?> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result == null || result.files.single.path == null) {
        throw Exception('Aucun fichier sélectionné.');
      }
      return result.files.single.path;
    } catch (e) {
      print('Erreur lors de la sélection du fichier PDF : $e');
      return null;
    }
  }

  Future<String> savePDF(PdfDocument pdf, {String? originalFileName}) async {
    try {
      final directory = Directory.systemTemp;
      String baseName = originalFileName != null
          ? originalFileName.replaceAll('.pdf', '') + '_Traduit.pdf'
          : 'translated_document.pdf';
      final filePath = '${directory.path}/$baseName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      return filePath;
    } catch (e) {
      print('Erreur lors de l\'enregistrement du PDF : $e');
      throw Exception('Impossible d\'enregistrer le PDF.');
    }
  }
}