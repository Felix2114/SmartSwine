import 'package:flutter/material.dart';
import 'data_page.dart';
import '../models/cerdo_model.dart';

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
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
        nombre: 'poke',
        raza: 'Pietrain',
        fechaNacimiento: DateTime(2023, 5, 21),
      ),
      Cerdo(
        id: 2,
        nombre: 'gil',
        raza: 'Duroc',
        fechaNacimiento: DateTime(2023, 8, 12),
      ),
      Cerdo(
        id: 3,
        nombre: 'emmanuel',
        raza: 'Landrace',
        fechaNacimiento: DateTime(2023, 11, 30),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'HISTORIAL',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF0F0F0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Busca por raza, edad o etapa de crecimiento',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: listaCerdos.length,
                itemBuilder: (context, index) {
                  final cerdo = listaCerdos[index];
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
                      breed: cerdo.raza, 
                      nombre: cerdo.nombre,
                      date:
                          '${cerdo.fechaNacimiento.day}/${cerdo.fechaNacimiento.month}/${cerdo.fechaNacimiento.year}',
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
  final String breed;
  final String nombre;
  final String date;

  const HistoryListItem({
    super.key,
    required this.breed,
    required this.nombre,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cruelty_free, size: 40, color: Colors.pink),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$breed  $nombre  $date',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}
