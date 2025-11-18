import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definición de colores
const Color _primaryColor = Color.fromARGB(255, 243, 33, 205); // Magenta
const Color _secondaryGreen = Color.fromARGB(255, 30, 130, 76); // Verde oscuro
const Color _backgroundColor = Color(0xFFF7F7F7); // Fondo muy claro

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. SECCIÓN DE PERFIL ---
            _buildProfileSection(context),
            const SizedBox(height: 30),

            // --- 2. SECCIÓN DE CUENTA ---
            _buildSettingsGroup(
              context,
              title: 'Ajustes de Cuenta',
              color: _primaryColor,
              items: [
                _buildSettingsItem(context, 'Cambiar Contraseña', Icons.lock_rounded, color: _primaryColor),
                _buildSettingsItem(context, 'Cambiar Correo', Icons.mail_rounded, color: _primaryColor),
                _buildSettingsItem(context, 'Gestión de Cuenta', Icons.manage_accounts_rounded, color: _primaryColor),
              ],
            ),
            const SizedBox(height: 30),

            // --- 3. SECCIÓN GENERAL ---
            _buildSettingsGroup(
              context,
              title: 'General',
              color: _secondaryGreen,
              items: [
                _buildSettingsItem(context, 'Notificaciones', Icons.notifications_active_rounded, color: _secondaryGreen),
                _buildSettingsItem(context, 'Idioma', Icons.language_rounded, color: _secondaryGreen),
                _buildSettingsItem(context, 'Privacidad y Seguridad', Icons.security_rounded, color: _secondaryGreen),
              ],
            ),
            const SizedBox(height: 30),

            // --- 4. SECCIÓN DE SOPORTE ---
            _buildSettingsGroup(
              context,
              title: 'Soporte',
              color: Colors.blue.shade700,
              items: [
                _buildSettingsItem(context, 'Ayuda y FAQs', Icons.help_outline_rounded, color: Colors.blue.shade700),
                _buildSettingsItem(context, 'Términos y Condiciones', Icons.description_rounded, color: Colors.blue.shade700),
                _buildSettingsItem(context, 'Cerrar Sesión', Icons.logout_rounded, color: Colors.red.shade700),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget 1: Sección de Perfil ---
  Widget _buildProfileSection(BuildContext context) {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: _primaryColor.withOpacity(0.8),
                child: const Icon(Icons.person, size: 45, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _secondaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Poke',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              Text(
                '@felix',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 5),
              Text(
                'Usuario Pro',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _secondaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // --- Widget 2: Grupo de Configuraciones ---
  Widget _buildSettingsGroup(BuildContext context, {required String title, required Color color, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        // Contenedor de las opciones
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) {
              // Añade un Divider excepto después del último item
              if (item != items.last) {
                return Column(
                  children: [
                    item,
                    Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey.shade200),
                  ],
                );
              }
              return item;
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- Widget 3: Elemento Individual de Configuración ---
  Widget _buildSettingsItem(BuildContext context, String title, IconData icon, {required Color color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade400),
      onTap: () {
        // Lógica de navegación a la pantalla de detalle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navegando a: $title', style: GoogleFonts.poppins()),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }
}