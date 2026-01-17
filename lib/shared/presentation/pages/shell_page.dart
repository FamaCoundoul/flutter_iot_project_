import 'package:flutter/material.dart';
import 'package:flutter_iot_project/features/sensors/presentation/pages/charts_page.dart';
import 'package:flutter_iot_project/features/sensors/presentation/pages/data_page.dart';
import 'package:flutter_iot_project/features/thresholds/presentation/pages/settings_page.dart';

// Import pages
import '../../../features/sensors/presentation/pages/home_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ChartsPage(),
    SettingsPage(),
    DataPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF667eea),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart_rounded),
                label: 'Graphiques',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Réglages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storage_rounded),
                label: 'Données',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
