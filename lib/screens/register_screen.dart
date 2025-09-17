import 'package:flutter/material.dart';

void main() {
  runApp(SmartSwineApp());
}

class SmartSwineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  // Color distintivo de tu app
  final Color pinkColor = const Color.fromARGB(255, 243, 33, 205);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: pinkColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/logo2SmartSwine.png', // Tu logo desde assets
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Título
            Text(
              'Create new Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // Subtítulo
            Text(
              'Already Registered? Log in here.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            SizedBox(height: 30),

            // Formulario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _textField('Adrian Ortega Gil'),
                  SizedBox(height: 15),
                  _textField('adrian.ort1011@gmail.com'),
                  SizedBox(height: 15),
                  _textField('******', obscureText: true),
                  SizedBox(height: 30),

                  // Botón Sign Up
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí va la lógica de registro
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Sign up', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String hint, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[300],
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
