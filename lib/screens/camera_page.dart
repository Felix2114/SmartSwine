import 'package:flutter/material.dart';
import 'confirm_page.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

       @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Entrar a confirmar datos'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfirmPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
