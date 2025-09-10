import 'package:flutter/material.dart';
import 'data_page.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Entrar a ver datos'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DataPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



