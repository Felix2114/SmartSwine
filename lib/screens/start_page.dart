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
    HomePage(),
    CameraPage(),
    AnalysisPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 243, 33, 205),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camara'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analisis'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
