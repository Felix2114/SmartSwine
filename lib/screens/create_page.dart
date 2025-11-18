import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);
const Color _backgroundColor = Color(0xFFF7F7F7);

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              ClipPath(
                clipper: InvertedCurvedClipper(),
                child: Container(
                  width: double.infinity,
                  height: 250, 
                  color: _primaryColor, 
                  child: Stack(
                    children: [
                      
                      Positioned(
                        top: 25,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                        ),
                      ),

                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Icon(Icons.person_add_alt_1_rounded, size: 60, color: _secondaryGreen), 
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              Text(
                'Crear Nueva\nCuenta',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '¿Ya estás registrado? Inicia sesión aquí.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _textField(
                      hint: "Nombre Completo",
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      hint: "Correo Electrónico",
                      icon: Icons.mail_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      hint: "Contraseña", 
                      icon: Icons.lock_rounded, 
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      hint: "Confirmar Contraseña", 
                      icon: Icons.lock_open_rounded, 
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica de registro
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _secondaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          'REGISTRARSE',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  
  static Widget _textField({
    required String hint, 
    IconData? icon, 
    bool obscureText = false, 
    TextInputType keyboardType = TextInputType.text
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      cursorColor: _primaryColor, 
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        prefixIcon: icon != null ? Icon(icon, color: _primaryColor) : null,
        
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        isDense: true,
        
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryColor, width: 2.5),
        ),
      ),
    );
  }
}


class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); 
    
    path.quadraticBezierTo(
      size.width / 2, 
      size.height + 20, 
      size.width, 
      size.height - 70 
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}