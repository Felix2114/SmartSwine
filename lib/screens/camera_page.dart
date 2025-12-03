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
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

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

  // CAMBIO 1: URL CORREGIDA. Apuntando al endpoint "/predict" de tu app.py
  final url = Uri.parse(
    "https://smartswine-poke.onrender.com/predict",
  );

  // Los headers ya no son necesarios porque usaremos MultipartRequest
  // final headers = {"Content-Type": "application/json"}; 
  
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
  // FUNCIÓN ELIMINADA: _processImage ya no es necesaria, el pre-procesamiento lo hace app.py
  //---------------------------------------------------------------------

  // CAMBIO 2: _startPrediction MODIFICADA para enviar la imagen como archivo (MultipartRequest)
  Future<void> _startPrediction() async {
    if (_pathImg == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Crear una solicitud MultipartRequest
      final request = http.MultipartRequest('POST', url);
      
      // 2. Adjuntar el archivo de imagen. El nombre del campo DEBE ser 'image'
      // para coincidir con request.files["image"] en tu app.py
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Clave del campo de archivo
          _pathImg!,
        ),
      );

      // 3. Enviar la solicitud y obtener la respuesta
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context);

      if (res.statusCode == 200) {
    // La respuesta de app.py es: {"class": "destete", "confidence": 0.98}
    final jsonPrediction = jsonDecode(res.body);

    final detectedClass = jsonPrediction["class"] as String;
    // La confianza viene como float (0.0 a 1.0)
    final confidenceValue = jsonPrediction["confidence"] as double;

    // AÑADIR ESTA LÍNEA AQUÍ
    await _savePredictionLog(detectedClass); // Guarda el log en Firestore

    _showPredictionResult(
      true,
      "Predicción Exitosa",
      "Etapa detectada: ${detectedClass.toUpperCase()}\n"
          "Confianza: ${(confidenceValue * 100).toStringAsFixed(2)}%",
    );

} else {
        // Manejar errores como el 400 Bad Request que puede enviar el servidor
        String errorMessage = "El servidor devolvió ${res.statusCode}.";
        try {
          final errorBody = jsonDecode(res.body);
          if (errorBody.containsKey("error")) {
            errorMessage = errorBody["error"];
          }
        } catch (_) {
          // Si no es JSON, mostrar el body crudo si es posible
          errorMessage = "${res.statusCode}: ${res.body}";
        }

        _showPredictionResult(
          false,
          "Error de API",
          errorMessage,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showPredictionResult(
        false,
        "Error de Conexión",
        "No se pudo contactar al servidor: $e",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Dentro de la clase _CameraPageState...

Future<void> _savePredictionLog(String stage) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _showErrorDialog("Error: Usuario no autenticado para guardar log.");
    return;
  }

  try {
    // Referencia a la base de datos de Firestore
    final db = FirebaseFirestore.instance;

    // Crear un mapa de datos para el log
    final logData = {
      'user_id': user.uid, // ID del usuario que hizo la predicción
      'stage_predicted': stage, // Etapa predicha (destete, crecimiento, engorda)
      'timestamp': FieldValue.serverTimestamp(), // Fecha y hora del registro
      // Puedes añadir más campos como 'image_url', 'confidence', etc.
    };

    // 1. Obtener la colección de logs del usuario
    // Creamos una subcolección 'logs' dentro del documento del usuario.
    // Asumimos que tienes una colección principal 'users' donde el ID del documento
    // es el UID del usuario.

    // Opción A: Guardar en una colección global 'prediction_logs'
    await db.collection("prediction_logs").add(logData);
    
    // Opción B (Recomendada si quieres ver historial por usuario): 
    // Guardar en la subcolección 'logs' del documento del usuario.
    /*
    await db.collection("users").doc(user.uid).collection("logs").add(logData);
    */

    print("Log de predicción guardado con éxito: $stage");

  } catch (e) {
    _showErrorDialog("Error al guardar el log de predicción en Firestore: $e");
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