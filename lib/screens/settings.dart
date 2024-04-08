import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:humantiy/constants.dart';
import 'package:humantiy/core/locator.dart';
import 'package:humantiy/core/services/data_services.dart';
import 'package:humantiy/core/services/location_services.dart';
import 'package:humantiy/theme/app_state_notify.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    void showLoadingDialog(BuildContext context, String _title) async {
      return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
                canPop: false,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: SimpleDialog(
                      backgroundColor: Colors.transparent,
                      children: <Widget>[
                        Center(
                          child: Container(
                            child: Column(children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.indigoAccent),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                _title,
                                style: TextStyle(color: Colors.white),
                              ),
                            ]),
                          ),
                        )
                      ]),
                ));
          });
    }

    Future<bool?> succesChange(String _title, String _desc) async {
      Navigator.pop(context);
      return Alert(
          type: AlertType.success,
          context: context,
          style: AlertStyle(
            titleStyle: TextStyle(fontSize: 16),
            descStyle: TextStyle(fontSize: 15),
          ),
          title: _title,
          desc: _desc,
          buttons: [
            DialogButton(
              child: Text(
                'Tamam',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
    }

    Future<bool?> failedChange(String _title, String _desc) {
      Navigator.pop(context);
      return Alert(
          type: AlertType.warning,
          context: context,
          style: AlertStyle(
            titleStyle: TextStyle(fontSize: 16),
            descStyle: TextStyle(fontSize: 15),
          ),
          title: _title,
          desc: _desc,
          buttons: [
            DialogButton(
              child: Text(
                'Tamam',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
    }

    void checkCurrentLocation() async {
      showLoadingDialog(context, 'Konum Güncelleniyor...');
      await Hive.openBox('myLocationsDb');
      var box = await Hive.box('myLocationsDb');
      var locationServices = getIt<LocationServices>();
      await locationServices.getPosition().then((position) async {
        var coordinateLocationModel = getIt<DataServicesFromCoordinate>(
          param1: position.latitude.toString(),
          param2: position.longitude.toString(),
        );
        final airDataModel =
            await coordinateLocationModel.getCityDataFromCoordinate();
        List<dynamic> tempAreas = await box.get('savedAreas') ?? [];
        tempAreas.isNotEmpty ? tempAreas.removeAt(0) : null;
        tempAreas.insert(0, [
          position.latitude,
          position.longitude,
          airDataModel.name,
          airDataModel.aqi
        ]);
        await box.put('savedAreas', tempAreas);
        await succesChange('Konum Başarıyla Güncellendi',
            'Yeni konumunuza ait verileri ana sayfa üzerinden görüntüleyebilirsiniz.');
      }).catchError((error) async {
        await failedChange('Konum Güncellenemedi',
            'Konumunuzu güncelleyemedik. Lütfen daha sonra tekrar deneyiniz.');
      });
      if (mounted) {
        setState(() {
          isGetCurrentLocation = true;
        });
      }
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.indigo,
                        ),
                        title: Text(
                          'Konumu Güncelle',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          checkCurrentLocation();
                          //ardından bizim ana fonksiyona yollamamız gerekiyor sanırım.
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Diğer Ayarlar',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SwitchListTile(
                  activeColor: Colors.indigoAccent,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    'Koyu Tema',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  onChanged: (isDarkModeEnabled) {
                    setState(() {
                      changeTheme(isDarkModeEnabled);
                      Provider.of<AppStateNotifier>(context, listen: false)
                          .updateTheme(isDarkModeEnabled);
                    });
                  },
                  value: Provider.of<AppStateNotifier>(context).isDarkMode,
                ),
                const SizedBox(height: 60.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changeTheme(bool theme) async {
    await Hive.openBox('theme');
    var box = await Hive.box('theme');
    await box.put('darktheme', theme);
  }
}
