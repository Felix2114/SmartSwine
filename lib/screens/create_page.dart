import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76);
const Color _backgroundColor = Color(0xFFF7F7F7);

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Controladores de texto
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool loading = false;

  Future<void> registerUser() async {
  final name = nameCtrl.text.trim();
  final email = emailCtrl.text.trim();
  final pass = passCtrl.text.trim();
  final confirm = confirmCtrl.text.trim();

  if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
    _showMessage("Por favor completa todos los campos.");
    return;
  }

  if (pass != confirm) {
    _showMessage("Las contraseñas no coinciden.");
    return;
  }

  try {
    setState(() => loading = true);

    // Crear usuario en Firebase Auth
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass);

    // Guardar nombre en Auth (displayName)
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();

    // =============================
    //  GUARDAR NOMBRE EN FIRESTORE
    // =============================
    final uid = credential.user!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "createdAt": DateTime.now(),
    });
    // =============================

    _showMessage("Cuenta creada correctamente 🎉");

    Navigator.pop(context);

  } on FirebaseAuthException catch (e) {
    _showMessage(e.message ?? "Error desconocido");
  } finally {
    setState(() => loading = false);
  }
}


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

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
                          child: const Icon(Icons.person_add_alt_1_rounded,
                              size: 60, color: _secondaryGreen),
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
                      controller: nameCtrl,
                      hint: "Nombre Completo",
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      controller: emailCtrl,
                      hint: "Correo Electrónico",
                      icon: Icons.mail_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      controller: passCtrl,
                      hint: "Contraseña",
                      icon: Icons.lock_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    _textField(
                      controller: confirmCtrl,
                      hint: "Confirmar Contraseña",
                      icon: Icons.lock_open_rounded,
                      obscureText: true,
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _secondaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
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
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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
      size.height - 70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
