import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_page.dart';
import '../models/cerdo_model.dart';

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Historial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const AnalysisPage(),
    );
  }
}

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Cerdo> listaCerdos = [
      Cerdo(
        id: 1,
        nombre: 'Poke',
        raza: 'Pietrain',
        fechaNacimiento: DateTime(2023, 5, 21),
      ),
      Cerdo(
        id: 2,
        nombre: 'Gil',
        raza: 'Duroc',
        fechaNacimiento: DateTime(2023, 8, 12),
      ),
      Cerdo(
        id: 3,
        nombre: 'Emmanuel',
        raza: 'Landrace',
        fechaNacimiento: DateTime(2023, 11, 30),
      ),
      Cerdo(
        id: 4,
        nombre: 'Maya',
        raza: 'Yorkshire',
        fechaNacimiento: DateTime(2024, 1, 15),
      ),
      Cerdo(
        id: 5,
        nombre: 'Zeus',
        raza: 'Hampshire',
        fechaNacimiento: DateTime(2023, 10, 5),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'HISTORIAL DE ANÁLISIS',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF7F7F7),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
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
                  hintText: 'Busca por nombre, raza o ID',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registros (${listaCerdos.length})',
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
                itemCount: listaCerdos.length,
                itemBuilder: (context, index) {
                  final cerdo = listaCerdos[index];
                  final String formattedDate = 
                      '${cerdo.fechaNacimiento.day.toString().padLeft(2, '0')}/'
                      '${cerdo.fechaNacimiento.month.toString().padLeft(2, '0')}/'
                      '${cerdo.fechaNacimiento.year}';
                      
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataPage(), 
                        ),
                      );
                    },
                    child: HistoryListItem(
                      id: cerdo.id,
                      breed: cerdo.raza, 
                      name: cerdo.nombre,
                      date: formattedDate,
                    ),
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


class HistoryListItem extends StatelessWidget {
  final int id;
  final String breed;
  final String name;
  final String date;

  const HistoryListItem({
    super.key,
    required this.id,
    required this.breed,
    required this.name,
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
              child: Icon(Icons.badge_rounded, size: 30, color: _secondaryGreen),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${id.toString().padLeft(3, '0')} - $name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Raza: $breed',
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
                  date,
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