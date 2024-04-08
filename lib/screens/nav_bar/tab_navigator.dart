import 'package:flutter/material.dart';
import 'package:humantiy/screens/information.dart';
import 'package:humantiy/screens/map_page/map_view.dart';
import 'package:humantiy/screens/home.dart';
import 'package:humantiy/screens/settings.dart';

class TabNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  const TabNavigator(
      {super.key, required this.navigatorKey, required this.tabItem});

  @override
  State<StatefulWidget> createState() => TabNavigatorState();
}

class TabNavigatorState extends State<TabNavigator> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.tabItem) {
      case "Ana Sayfa":
        child = Scaffold(
            appBar: AppBar(
              title: Text('Humantiy'),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Information();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
            body: Home());

        break;
      case "Harita":
        child = Scaffold(
            appBar: AppBar(
              title: Text('Humantiy'),
            ),
            body: MapView());
        break;
      case "Ayarlar":
        child = Scaffold(
            appBar: AppBar(
              title: Text('Humantiy'),
            ),
            body: Settings());
      default:
        child = CircularProgressIndicator();
    }

    return Container(
      child: child,
    );
  }
}
