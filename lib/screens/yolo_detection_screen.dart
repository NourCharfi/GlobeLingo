import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/yolo_coco_labels.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class YoloDetectionScreen extends StatefulWidget {
  @override
  _YoloDetectionScreenState createState() => _YoloDetectionScreenState();
}

class _YoloDetectionScreenState extends State<YoloDetectionScreen> {
  Interpreter? _interpreter;
  File? _image;
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  int _inputSize = 640; // Adapter selon le modèle YOLO utilisé

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/yolov5s_f16.tflite');
    } catch (e) {
      print('Erreur chargement modèle: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _results = [];
      });
      await _runYoloOnImage(_image!);
    }
  }

  Future<void> _runYoloOnImage(File imageFile) async {
    setState(() { _isLoading = true; });
    final imageBytes = await imageFile.readAsBytes();
    final oriImage = img.decodeImage(imageBytes)!;
    final inputImage = img.copyResize(oriImage, width: _inputSize, height: _inputSize);
    // Normalisation [0,1]
    var input = List.generate(_inputSize, (y) => List.generate(_inputSize, (x) => List.filled(3, 0.0)));
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = inputImage.getPixel(x, y);
        // Correction : utiliser les getters r, g, b de la classe Pixel (image >=4.x)
        input[y][x][0] = pixel.r / 255.0;
        input[y][x][1] = pixel.g / 255.0;
        input[y][x][2] = pixel.b / 255.0;
      }
    }
    var inputTensor = [input];
    var output = List.generate(1, (i) => List.filled(25200 * 85, 0.0));
    _interpreter?.run(inputTensor, output);
    // Post-traitement réel
    final results = await _yoloPostProcess(output, _inputSize, oriImage);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  // Ajout : récupération du résumé Wikipédia pour chaque label détecté
  Future<String> _getWikipediaSummary(String label, String lang) async {
    final url = 'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(label)}';
    try {
      final response = await HttpClient().getUrl(Uri.parse(url)).then((req) => req.close());
      if (response.statusCode == 200) {
        final jsonStr = await response.transform(const Utf8Decoder()).join();
        final data = json.decode(jsonStr);
        if (data['extract'] != null && data['extract'].toString().trim().isNotEmpty) {
          return data['extract'];
        }
      }
    } catch (_) {}
    return '';
  }

  Future<List<Map<String, dynamic>>> _yoloPostProcess(List output, int inputSize, img.Image oriImage, {double confThreshold = 0.4, double iouThreshold = 0.45}) async {
    // output: [1, 25200*85] pour yolov5s 640x640
    final List<Map<String, dynamic>> results = [];
    final List boxes = [];
    final List scores = [];
    final List classIds = [];
    final width = oriImage.width;
    final height = oriImage.height;
    final numPred = 25200; // pour yolov5s
    final numClasses = 80;
    final raw = output[0];
    for (int i = 0; i < numPred; i++) {
      final conf = raw[i * (numClasses + 5) + 4];
      if (conf < confThreshold) continue;
      // Trouver la classe avec le score le plus élevé
      double maxClass = 0;
      int classId = 0;
      for (int c = 0; c < numClasses; c++) {
        final score = raw[i * (numClasses + 5) + 5 + c];
        if (score > maxClass) {
          maxClass = score;
          classId = c;
        }
      }
      final score = conf * maxClass;
      if (score < confThreshold) continue;
      // Box format YOLO: cx, cy, w, h (normalisés sur inputSize)
      final cx = raw[i * (numClasses + 5) + 0] * width / inputSize;
      final cy = raw[i * (numClasses + 5) + 1] * height / inputSize;
      final w = raw[i * (numClasses + 5) + 2] * width / inputSize;
      final h = raw[i * (numClasses + 5) + 3] * height / inputSize;
      final x = cx - w / 2;
      final y = cy - h / 2;
      boxes.add([x, y, w, h]);
      scores.add(score);
      classIds.add(classId);
    }
    // NMS (suppression des doublons)
    final keep = nms(boxes, scores, iouThreshold);
    for (final idx in keep) {
      final label = yoloCocoLabels[classIds[idx]];
      final summary = await _getWikipediaSummary(label, 'fr');
      results.add({
        'label': label,
        'score': scores[idx],
        'box': boxes[idx],
        'summary': summary,
      });
    }
    return results;
  }

  // NMS rapide (IoU)
  List<int> nms(List boxes, List scores, double iouThreshold) {
    final List<int> keep = [];
    final List<int> idxs = List.generate(scores.length, (i) => i);
    idxs.sort((a, b) => scores[b].compareTo(scores[a]));
    while (idxs.isNotEmpty) {
      final current = idxs.removeAt(0);
      keep.add(current);
      idxs.removeWhere((i) => iou(boxes[current], boxes[i]) > iouThreshold);
    }
    return keep;
  }

  double iou(List boxA, List boxB) {
    final xA = boxA[0] > boxB[0] ? boxA[0] : boxB[0];
    final yA = boxA[1] > boxB[1] ? boxA[1] : boxB[1];
    final xB = (boxA[0] + boxA[2]) < (boxB[0] + boxB[2]) ? (boxA[0] + boxA[2]) : (boxB[0] + boxB[2]);
    final yB = (boxA[1] + boxA[3]) < (boxB[1] + boxB[3]) ? (boxA[1] + boxA[3]) : (boxB[1] + boxB[3]);
    final interArea = (xB - xA).clamp(0, double.infinity) * (yB - yA).clamp(0, double.infinity);
    final boxAArea = boxA[2] * boxA[3];
    final boxBArea = boxB[2] * boxB[3];
    return interArea / (boxAArea + boxBArea - interArea);
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détection d\'objets'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Caméra'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Galerie'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_image != null)
              Stack(
                children: [
                  Container(
                    height: 220,
                    child: Image.file(_image!),
                  ),
                  if (_results.isNotEmpty)
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final scaleX = constraints.maxWidth / _inputSize;
                          final scaleY = 220 / _inputSize;
                          return Stack(
                            children: _results.map((r) {
                              final box = r['box'];
                              return Positioned(
                                left: box[0] * scaleX,
                                top: box[1] * scaleY,
                                width: box[2] * scaleX,
                                height: box[3] * scaleY,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      color: Colors.red.withOpacity(0.7),
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text(
                                        '${r['label']} ${(r['score'] * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                ],
              ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, idx) {
                    final r = _results[idx];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Objet : ${r['label']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Score : ${(r['score'] * 100).toStringAsFixed(1)}%'),
                            if ((r['summary'] ?? '').isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text('Définition Wikipédia :', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                              Text(r['summary'], style: TextStyle(fontSize: 14)),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_results.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.save_alt),
                    label: Text('Exporter résultats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final export = _results.map((r) =>
                        'Objet : ${r['label']}\nScore : ${(r['score']*100).toStringAsFixed(1)}%\nDéfinition Wikipédia :\n${r['summary'] ?? ''}\n---'
                      ).join('\n');
                      final directory = await getExportDirectory();
                      final file = File('${directory.path}/yolo_results_${DateTime.now().millisecondsSinceEpoch}.txt');
                      await file.writeAsString(export);
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Résultats exportés'),
                          content: Text('Fichier enregistré :\n${file.path}'),
                          actions: [
                            TextButton(
                              child: Text('Fermer'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Ajout utilitaire pour obtenir le dossier d'export (Android/iOS compatible)
Future<Directory> getExportDirectory() async {
  if (Platform.isAndroid) {
    final dir = Directory('/storage/emulated/0/Download');
    if (await dir.exists()) return dir;
    return await Directory.systemTemp.createTemp();
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  } else {
    return await Directory.systemTemp.createTemp();
  }
}
