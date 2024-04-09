import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart';
import 'map_page/map_view.dart';
import 'settings.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(label: 'Ana Sayfa', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Harita', icon: Icon(Icons.map)),
          NavigationDestination(label: 'Ayarlar', icon: Icon(Icons.settings))
        ],
      ),
      body: [
        Home(),
        MapView(),
        Settings(),
      ][currentPageIndex],
    );
  }
}
