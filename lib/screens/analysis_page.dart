import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_page.dart'; // Asumo que DataPage es la pantalla de detalles

// 1. IMPORTACIONES DE FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatear el timestamp

// NOTA: ELIMINAMOS 'package:../models/cerdo_model.dart' y la lista estática.

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);
const Color _backgroundColor = Color(0xFFF7F7F7); // Definimos el color aquí

void main() {
  // Asegúrate de inicializar Firebase en tu main.dart principal
  // runApp(const MyApp());
}

// ... MyApp se mantiene igual ...

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización del formateador de fecha (Seguimos el patrón más simple)
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final user = FirebaseAuth.instance.currentUser;

    // 🛑 Manejar el caso de usuario no autenticado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historial')),
        body: const Center(child: Text("Por favor, inicie sesión para ver el historial.")),
      );
    }
    
    // 2. CONSULTA A FIRESTORE
    final logsStream = FirebaseFirestore.instance
        .collection('prediction_logs')
        .where('user_id', isEqualTo: user.uid)
        // Usamos el mismo orden que requiere el índice compuesto
        .orderBy('timestamp', descending: true) 
        .limit(20)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  automaticallyImplyLeading: false, // 🚫 Quita la flecha de regresar
  title: Text(
    'HISTORIAL DE ANÁLISIS',
    style: GoogleFonts.poppins(
      color: _primaryColor,
      fontWeight: FontWeight.w700,
      fontSize: 20,
    ),
  ),
  centerTitle: true,
),
      body: Container(
        color: _backgroundColor, // Usamos la constante
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 3. BARRA DE BÚSQUEDA (Se mantiene)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: _primaryColor),
                  hintText: 'Busca por etapa o fecha', // Texto hint actualizado
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. STREAMBUILDER PARA CARGAR DATOS DE FIRESTORE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: logsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar historial: ${snapshot.error}', textAlign: TextAlign.center,));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final logs = snapshot.data!.docs;

                  if (logs.isEmpty) {
                    return Center(
                      child: Text(
                        'Aún no hay predicciones en tu historial.',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  // Título con conteo de registros
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registros (${logs.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(Icons.filter_list_rounded, color: _secondaryGreen, size: 24),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final doc = logs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            
                            // Obtener datos de Firestore
                            final stage = data['stage_predicted'] as String? ?? 'Desconocida';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final logId = doc.id; // Usamos el ID del documento como identificador

                            String dateStr = timestamp != null 
                                ? dateFormat.format(timestamp.toDate()) 
                                : 'Fecha Desconocida';
                                
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // Puedes pasar el ID del log a DataPage si esta es la página de detalles
                                    builder: (context) => const DataPage(), 
                                  ),
                                );
                              },
                              child: HistoryListItem(
                                // Adaptamos los datos al HistoryListItem
                                id: logId, 
                                stage: stage, // Nuevo campo
                                date: dateStr,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. MODIFICACIÓN DEL WIDGET HistoryListItem
class HistoryListItem extends StatelessWidget {
  final String id; // Cambiamos a String para guardar el doc ID de Firestore
  final String stage; // Nuevo campo: la etapa predicha
  final String date;

  const HistoryListItem({
    super.key,
    required this.id,
    required this.stage, // Usamos stage en lugar de breed
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _primaryColor.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _secondaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              // Icono que representa la etapa/log
              child: Icon(Icons.analytics_rounded, size: 30, color: _secondaryGreen),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Mostramos la etapa como título
                    'Etapa: ${stage.toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    // Mostramos el ID del log (o puedes usar un nombre/raza si lo agregaste)
                    'ID Registro: ${id.substring(0, 8)}...',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  // Fecha completa
                  date.split(' ')[0],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  // Hora
                  date.split(' ')[1],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}