import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:humantiy/constants.dart';
import 'package:humantiy/core/services/data_services.dart';
import 'package:humantiy/models/air_data_model.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/locator.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  List<String> locationDataContent = [
    'null',
    'null',
    'null',
    'null',
    'null',
    'null'
  ];
  final List<String> locationDataTitles = [
    'Bölge Adı: ',
    'Hava Kalitesi:',
    'Karbonmonoksit:',
    'Pm2.5:',
    'Pm10:',
    'Güncellenme:'
  ];
  // var markerList = <Marker>[];
  var showDetails = false;
  var isLoading = false;
  late AirDataModel airData;
  late MaplibreMapController mapController;
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(39.179565, 34.455683),
    zoom: 5,
  );
  final bool _compassEnabled = true;
  final MinMaxZoomPreference _minMaxZoomPreference =
      MinMaxZoomPreference(5, 20);
  final int _styleStringIndex = 1;
  final List<String> _styleStrings = [
    "https://demotiles.maplibre.org/style.json",
    "assets/style.json"
  ];
  final bool _rotateGesturesEnabled = true;
  final bool _scrollGesturesEnabled = true;
  bool? _doubleClickToZoomEnabled;
  final bool _tiltGesturesEnabled = true;
  final bool _zoomGesturesEnabled = true;

  @override
  void initState() {
    _loadDefaults();
    super.initState();
  }

  Future _getLocalArea() async {
    await Hive.openBox('myLocationsDb');
    var box = Hive.box('myLocationsDb');
    var savedAreas = await box.get('savedAreas');
    return savedAreas;
  }

  void _loadDefaults() async {}

  void _saveAreaToLocal(data) async {
    await Hive.openBox('myLocationsDb');
    var box = Hive.box('myLocationsDb');
    var savedAreas = await box.get('savedAreas');
    var newSaveArea = compileAreaDataForSave(await data);
    savedAreas != null ? savedAreas.add(newSaveArea[0]) : null;
    var lastSavedData = savedAreas ?? newSaveArea;
    await box.put('savedAreas', lastSavedData);
    isSavedNewArea = true;
    showDetails = false;
    if (mounted) {
      setState(() {});
    }
  }

  List<dynamic> compileAreaDataForSave(AirDataModel airDataModel) {
    var tempSavedAreas = [];
    tempSavedAreas.insert(0, [
      airDataModel.lat,
      airDataModel.lng,
      airDataModel.name,
      airDataModel.aqi
    ]);
    return tempSavedAreas;
  }

  void closeDetails() {
    if (mounted) {
      setState(() {
        showDetails = false;
      });
    }
  }

  Widget detailsWidget(Size size) {
    return Container(
      width: size.width - 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: showDetails
                ? AnimatedCrossFade(
                    firstChild: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  )),
                              onPressed: () => closeDetails(),
                              child: Text(
                                'Kapat',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  )),
                              onPressed: () => _saveAreaToLocal(airData),
                              child: Text(
                                'Kaydet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: locationDataTitles.length,
                          itemBuilder: (context, index) {
                            return Offstage(
                              offstage: locationDataContent[index] == 'null',
                              child: Container(
                                height: 40,
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        locationDataTitles[index],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(locationDataContent[index],
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    secondChild: Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.grey.withOpacity(.6),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Container(
                              alignment: Alignment.center,
                              width: size.width * .7,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    duration: Duration(milliseconds: 200),
                    crossFadeState:
                        isLoading || locationDataContent[3] == 'null'
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                  )
                : Text('Bir Konum Seçin')),
      ),
    );
  }

  // _handleOnTap(LatLng latlng) async {
  //   isLoading = true;
  //   showDetails = true;
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   airData =
  //       await _getData(latlng.latitude.toString(), latlng.longitude.toString());
  //   var time = airData.time.toString();
  //   time = time.substring(0, time.length - 3);

  //   locationDataContent.insert(0, airData.name);
  //   locationDataContent.insert(1, airData.aqi.toString());
  //   locationDataContent.insert(2, airData.co.toString());
  //   locationDataContent.insert(3, airData.pm25.toString());
  //   locationDataContent.insert(4, airData.pm10.toString());
  //   locationDataContent.insert(5, time);
  //   isLoading = false;
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  Future<AirDataModel> _getData(String lat, String lng) async {
    var model = getIt<DataServicesFromCoordinate>(
      param1: lat,
      param2: lng,
    );
    final selectedAreaData = await model.getCityDataFromCoordinate();
    return selectedAreaData;
  }

  Color getColor(aqi) {
    var color = Colors.white;

    if (aqi <= 50) {
      color = Colors.green;
    } else if (aqi <= 100) {
      color = Colors.yellow[700]!;
    } else if (aqi <= 150) {
      color = Colors.deepOrange;
    } else if (aqi <= 200) {
      color = Colors.red;
    } else if (aqi <= 300) {
      color = Colors.purple;
    }
    return color;
  }

  // void createMarkers(data) {
  //   if (data != null) {
  //     var newMarker = Marker(
  //       width: 80.0,
  //       height: 80.0,
  //       point: LatLng(data[0], data[1]),
  //       builder: (context) => Container(
  //           child: Column(
  //         children: <Widget>[
  //           Icon(
  //             Icons.location_on,
  //             color: getColor(data[data.length - 1]),
  //             size: 50,
  //           ),
  //         ],
  //       )),
  //     );
  //     markerList.add(newMarker);
  //   }
  // }

  // FlutterMap buildFlutterMap(AsyncSnapshot snapshot) {
  //   markerList = <Marker>[];
  //   var data = snapshot.data;
  //   data != null ? data.forEach((location) => createMarkers(location)) : null;
  //   return FlutterMap(
  //     options: MapOptions(
  //       onTap: _handleOnTap,
  //       plugins: [
  //         MarkerClusterPlugin(),
  //       ],
  //       zoom: 5.0,
  //       minZoom: 2.0,
  //       maxZoom: 20.0,
  //       center: LatLng(39.179565, 34.455683),
  //     ),
  //     layers: [
  //       TileLayerOptions(
  //         maxZoom: 20,
  //         urlTemplate: 'http://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
  //         subdomains: ['0', '1', '2', '3'],
  //         tileProvider: NonCachingNetworkTileProvider(),
  //       ),
  //       MarkerLayerOptions(markers: markerList)
  //     ],
  //   );
  // }

  MaplibreMap createMap(AsyncSnapshot snapshot) {
    return MaplibreMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      trackCameraPosition: true,
      compassEnabled: _compassEnabled,
      minMaxZoomPreference: _minMaxZoomPreference,
      styleString: _styleStrings[_styleStringIndex],
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      doubleClickZoomEnabled: _doubleClickToZoomEnabled,
      // myLocationEnabled: _myLocationEnabled,
      // myLocationTrackingMode: _myLocationTrackingMode,
      // myLocationRenderMode: MyLocationRenderMode.GPS,
      onMapClick: onMapClick,
      onStyleLoadedCallback: onStyleLoadedCallback,
    );
  }

  void onMapCreated(MaplibreMapController controller) {
    mapController = controller;
  }

  void onMapClick(point, latLng) async {
    List features =
        await mapController.queryRenderedFeatures(point, ["points-lyr"], null);
    if (!mounted) return;
    if (features.isEmpty) return;
    final feature = features.first;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(feature["geometry"]["coordinates"][1],
            feature["geometry"]["coordinates"][0]),
        16));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feature["properties"]["name"],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void onStyleLoadedCallback() async {
    debugPrint("Style loaded callback");
    await mapController.addGeoJsonSource(
      "points-src",
      {
        "type": "FeatureCollection",
        "features": [],
      },
    );
    await mapController.addCircleLayer(
      "points-src",
      "points-lyr",
      CircleLayerProperties(
        circleRadius: 6,
        circleColor: Colors.blueAccent.toHexStringRGB(),
        circleStrokeWidth: 2,
        circleStrokeColor: Colors.orangeAccent.toHexStringRGB(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        FutureBuilder(
            future: _getLocalArea(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return createMap(snapshot);
                    // return showInfo(context, snapshot);
                  }
              }
            }),
        Positioned(bottom: 1, child: detailsWidget(size))
      ],
    );
  }
}
