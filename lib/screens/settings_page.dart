import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

// Colores base
const Color _primaryColor = Color.fromARGB(255, 243, 33, 205);
const Color _backgroundColor = Color(0xFFF7F7F7);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(
            color: _primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 40),

            _aboutButton(context),
            const SizedBox(height: 20),

            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  // ---------------- PERFIL ----------------
Widget _buildProfileCard() {
  final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Usuario";

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _primaryColor.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: _primaryColor.withOpacity(0.85),
          child: const Icon(Icons.person, size: 45, color: Colors.white),
        ),
        const SizedBox(width: 15),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '@${userName.toLowerCase().replaceAll(" ", "")}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        const Spacer(),
      ],
    ),
  );
}


  // ---------------- BOTÓN ACERCA DE ----------------
  Widget _aboutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.info_outline, color: _primaryColor, size: 26),
        ),
        title: Text(
          "Acerca de",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 55,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Acerca de la App",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      "Aplicación desarrollada para predecir la etapa de crecimiento de un cerdo "
                      "usando una imagen o fotografía. Utiliza modelos de visión artificial "
                      "para ofrecer resultados rápidos y precisos.",
                      style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 25),

                    Text(
                      "Versión 1.0.0",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- BOTÓN DE CERRAR SESIÓN ----------------
 // ---------------- BOTÓN DE CERRAR SESIÓN ----------------
Widget _logoutButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 26),
      ),
      title: Text(
        "Cerrar Sesión",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
      onTap: () async {
        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      },
    ),
  );
}



}


