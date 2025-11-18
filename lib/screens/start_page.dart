import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'camera_page.dart';
import 'home_page.dart';
import 'analysis_page.dart';

class StartPage extends StatefulWidget {
  final int initialIndex;
  const StartPage({super.key, this.initialIndex = 0});

  @override
  State<StartPage> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; 
  }

  final List<Widget> _screens = const [
    FunHomePage(),
    CameraPage(),
    AnalysisPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 
  final Color _primaryColor = const Color.fromARGB(255, 243, 33, 205);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: Container(
       
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          
         
          type: BottomNavigationBarType.fixed, 
          elevation: 0, 
          backgroundColor: Colors.transparent, 
          
         
          selectedItemColor: _primaryColor, 
          unselectedItemColor: Colors.grey.shade600, 

          showSelectedLabels: true, 
          showUnselectedLabels: false, 
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            color: _primaryColor,
          ),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Camara'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analisis'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Configuración'),
          ],
        ),
      ),
      
    );
  }
}