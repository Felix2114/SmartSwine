import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'start_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);
const Color _backgroundColor = Color(0xFFF7F7F7);

class DataPage extends StatelessWidget {
  // Nota: Se recomienda quitar 'const' del constructor para evitar errores de compilación
  // con variables final no-constantes, o usar 'late final' y quitar 'const' del constructor.
  // Por simplicidad, inicializamos el DateFormat dentro del build.
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización del DateFormat dentro del build para evitar conflictos de 'const'
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final user = FirebaseAuth.instance.currentUser;

    // Asegurar que el usuario esté autenticado
    if (user == null) {
      return const Center(child: Text("Por favor, inicie sesión."));
    }

    // Consulta a Firestore: filtrar por usuario y ordenar por fecha
    final logsStream = FirebaseFirestore.instance
        .collection('prediction_logs')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () {
            // Asumo que quieres ir a la segunda pestaña (index 2) de StartPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StartPage(initialIndex: 2),
              ),
            );
          },
        ),
        title: Text(
          'HISTORIAL DE ANÁLISIS',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: logsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Muestra el error de índice si ocurre
            return Center(child: Text('Error al cargar historial: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay documentos
          final logs = snapshot.data!.docs;
          if (logs.isEmpty) {
            return Center(
              child: Text(
                'Aún no tienes predicciones en tu historial.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Construir la lista con los resultados
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              final stage = log['stage_predicted'] as String? ?? 'N/D';
              final timestamp = log['timestamp'] as Timestamp?;
              
              String dateStr = timestamp != null 
                  ? dateFormat.format(timestamp.toDate()) 
                  : 'Fecha Desconocida';
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(
                    Icons.assignment_turned_in_rounded, 
                    color: _primaryColor,
                  ),
                  title: Text(
                    stage.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, 
                      fontSize: 18
                    ),
                  ),
                  subtitle: Text(
                    'Predicción realizada el $dateStr',
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Acción al hacer tap
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}