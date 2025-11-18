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

  final url = Uri.parse(
    
    "https://tensorflow-signs-model-latest.onrender.com/v1/models/signs-model:predict",
    //"https://model-flowers-felix.onrender.com/v1/models/signs-model:predict",

  ); 
  final headers = {"Content-Type": "application/json;charset=UTF-8"};



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
    } on PlatformException catch (e) {
      _showErrorDialog("Error de permisos o cámara no disponible: $e");
      setState(() => _isLoading = false); 
    } catch (e) {
      _showErrorDialog("Ocurrió un error al cargar la imagen.");
      setState(() => _isLoading = false); 
    }
  }



  Future<List<List<List<double>>>> _processImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return [];

   
    img.Image grayscale = img.grayscale(image);

   
    img.Image resized = img.copyResize(grayscale, width: 300, height: 300);

    
    List<List<List<double>>> result = List.generate(
      300,
      (i) => List.generate(300, (j) {
       
        int pixel = resized.getPixel(j, i);
        double value = (pixel & 0xFF) / 255.0; 
        return [value]; 
      }),
    );

    return result;
  }


  Future<void> _startPrediction() async {
    if (_pathImg == null) return;

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final processedImage = await _processImage(File(_pathImg!));

      
      final predictionInstance = {
        "instances": [processedImage]
      };

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(predictionInstance),
      );

     
      Navigator.pop(context); 

      if (res.statusCode == 200) {
        final jsonPrediction = jsonDecode(res.body);
        final pred = jsonPrediction['predictions'][0] as List;
        
        final maxIndex = pred.indexOf(pred.reduce((a, b) => a > b ? a : b));

        
        final value = await rootBundle.loadString('assets/json/index.json');
        var datos = json.decode(value);
        var classResultPrediction = datos[maxIndex.toString()][1]; 

        _showPredictionResult(
          true, 
          "¡Predicción Exitosa!", 
          "Clase ID: $maxIndex\nResultado: $classResultPrediction"
        );
      } else {
       
        _showPredictionResult(
          false, 
          "Error de API", 
          "El servidor de predicción devolvió el código ${res.statusCode}. Revise la URL o el nombre del modelo."
        );
      }
    } catch (e) {
      if(mounted) Navigator.pop(context); 
      _showPredictionResult(
        false, 
        "Error de Conexión", 
        "No se pudo contactar al servidor. Error: ${e.toString()}"
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  

  void _showPredictionResult(bool success, String title, String desc) {
    AlertType type = success ? AlertType.success : AlertType.error;
    Color buttonColor = success ? _secondaryGreen : _primaryColor;
    String buttonText = success ? "Aceptar" : "Reintentar";

    Alert(
      context: context,
      type: type,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            buttonText,
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
    if(mounted) {
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
          "Análisis de la etapa del cerdo",
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
             
              Text(
                ' Predicción sobre la imagen del cerdo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Verifica la foto del cerdo antes de enviarla para su análisis.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 40),

           
              _SelectionCard(
                title: 'Capturar Imagen de tu cerdo',
                subtitle: 'Tomar una foto para enviar al modelo de predicción.',
                icon: Icons.photo_camera_rounded,
                color: _primaryColor,
                onTap: _isLoading ? null : () => _pickAndPredictImage(ImageSource.camera), 
                isLoading: _isLoading,
                tag: 'CÁMARA',
              ),
              const SizedBox(height: 25),

           
              _SelectionCard(
                title: 'Seleccionar Archivo',
                subtitle: 'Usar una imagen existente para la predicción.',
                icon: Icons.collections_bookmark_rounded,
                color: _secondaryGreen, 
                onTap: _isLoading ? null : () => _pickAndPredictImage(ImageSource.gallery), 
                isLoading: _isLoading,
                tag: 'ARCHIVO',
              ),
              
              const SizedBox(height: 50),

             
              if (_imageFile != null)
                Column(
                  children: [
                    Text(
                      'Última muestra enviada (300x300 Grises):', 
                      style: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.file(
                          _imageFile!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                  const SizedBox(width: 15),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Center(
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 5),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}