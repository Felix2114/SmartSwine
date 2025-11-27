import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:rflutter_alert/rflutter_alert.dart';

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);
const Color _backgroundColor = Color(0xfff8e8ff);

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  String? _pathImg;

  // CAMBIA ESTA URL POR LA DE TU MODELO EN RENDER
  final url = Uri.parse(
    "https://smartswine-poke.onrender.com/v1/models/pig-classifier:predict",
  );

  final headers = {"Content-Type": "application/json"};

  Future<File> _saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    return File(imagePath).copy('${directory.path}/$name');
  }

  Future<void> _pickAndPredictImage(ImageSource source) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _imageFile = null;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final imagePermanent = await _saveFilePermanently(pickedFile.path);

        setState(() {
          _imageFile = imagePermanent;
          _pathImg = imagePermanent.path;
        });

        await _startPrediction();

      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorDialog("Error capturando imagen: $e");
      setState(() => _isLoading = false);
    }
  }

  //---------------------------------------------------------------------
  // 🔥 NUEVA VERSIÓN — compatible con MobileNetV2 (RGB, 224x224, 0–1)
  //---------------------------------------------------------------------
  Future<List<List<List<List<double>>>>> _processImage(File file) async {
  final bytes = await file.readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image == null) return [];

  // ✔️ CORREGIDO — copyRotate usa argumentos POSICIONALES
  image = img.copyResize(
    img.copyRotate(image, 0),
    width: 224,
    height: 224,
  );

  List<List<List<double>>> result = List.generate(
    224,
    (y) => List.generate(
      224,
      (x) {
        final pixel = image!.getPixel(x, y);

        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;

        return [r, g, b];
      },
    ),
  );

  return [result];
}

  Future<void> _startPrediction() async {
    if (_pathImg == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final processed = await _processImage(File(_pathImg!));

      final predictionInstance = {
        "instances": processed,
      };

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(predictionInstance),
      );

      Navigator.pop(context);

      if (res.statusCode == 200) {
        final jsonPrediction = jsonDecode(res.body);
        final pred = jsonPrediction["predictions"][0] as List;

        // obtener índice con mayor probabilidad
        int maxIndex = 0;
        double maxValue = pred[0];

        for (int i = 1; i < pred.length; i++) {
          if (pred[i] > maxValue) {
            maxValue = pred[i];
            maxIndex = i;
          }
        }

        // 🔥 clases del modelo
        final classes = ["destete", "crecimiento", "engorda"];

        _showPredictionResult(
          true,
          "Predicción Exitosa",
          "Etapa detectada: ${classes[maxIndex].toUpperCase()}\n"
              "Confianza: ${(maxValue * 100).toStringAsFixed(2)}%",
        );

      } else {
        _showPredictionResult(
          false,
          "Error",
          "El servidor devolvió ${res.statusCode}. Revisa la URL del modelo.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showPredictionResult(
        false,
        "Error",
        "No se pudo contactar al servidor: $e",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPredictionResult(bool success, String title, String desc) {
    AlertType type = success ? AlertType.success : AlertType.error;
    Color buttonColor = success ? _secondaryGreen : _primaryColor;

    Alert(
      context: context,
      type: type,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: buttonColor,
          width: 120,
        )
      ],
    ).show();
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Análisis de etapa del cerdo",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text(
                'Predicción sobre la imagen del cerdo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              _SelectionCard(
                title: 'Tomar Foto',
                subtitle: 'Usar la cámara para analizar un cerdo.',
                icon: Icons.camera_alt_rounded,
                color: _primaryColor,
                onTap: _isLoading ? null : () => _pickAndPredictImage(ImageSource.camera),
                isLoading: _isLoading,
                tag: 'CÁMARA',
              ),

              const SizedBox(height: 20),

              _SelectionCard(
                title: 'Subir Imagen',
                subtitle: 'Selecciona una foto desde la galería.',
                icon: Icons.photo_library_rounded,
                color: _secondaryGreen,
                onTap: _isLoading ? null : () => _pickAndPredictImage(ImageSource.gallery),
                isLoading: _isLoading,
                tag: 'ARCHIVO',
              ),

              const SizedBox(height: 40),

              if (_imageFile != null)
                Column(
                  children: [
                    Text(
                      "Última imagen analizada:",
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Image.file(_imageFile!, width: 200, height: 200, fit: BoxFit.cover),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final String tag;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLoading,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
