import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:safego/model/api/directions.dart';



class RoadPlanPage extends StatefulWidget {
  const RoadPlanPage({Key? key}) : super(key: key);

  @override
  State<RoadPlanPage> createState() => _RoadPlanPageState();
}

class _RoadPlanPageState extends State<RoadPlanPage> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('GPS 沒開啟');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('沒有權限使用 GPS');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
  PolylinePoints polylinePoints = PolylinePoints();
  final RemoteConfig remoteConfig = RemoteConfig.instance;
  List<LatLng> polylineCoordinates = [];
  LatLng? sourceLocation;
  LatLng? destination;
  Set<Polyline> polylines = {};
  Set<Marker> markers = Set();


  String googleApikey = "";
  String location = "Search Location";

  final TextEditingController _startPlace = TextEditingController();
  final TextEditingController _endPlace = TextEditingController();

  Position? position;
  String? city;

  GoogleMapController? mapController;
  LatLng defaultLocation = LatLng(25.0339206, 121.5636985); // 初始位置固定在台北

  initState() {
    super.initState();
    _determinePosition;
    polylinePoints = PolylinePoints();
    getCity();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    try {
      await remoteConfig.fetchAndActivate();
      googleApikey = remoteConfig.getString("googleApikey");
      print("google api key = $googleApikey");
    } catch (exception) {
      print("_loadRemoteConfig ERROR");
    }
  }

  void addMarker() {
    markers.add(Marker(
      markerId: MarkerId(sourceLocation.toString()),
      position: sourceLocation!,
      infoWindow: InfoWindow(
        title: '出發點',
        // snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));

    markers.add(Marker(
      markerId: MarkerId(destination.toString()),
      position: destination!,
      infoWindow: InfoWindow(
        title: '目的地',
        // snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    setState(() {});
  }
  void suggested() async {
    addMarker();
  }

  void faster() async {
    addMarker();
    var mapsResult = await Directions().directions(sourceLocation!,destination!,googleApikey);
    String? overviewPolyline = mapsResult['routes'][0]['overview_polyline']['points'];
    List<PointLatLng> result = polylinePoints.decodePolyline(overviewPolyline!);
    List<LatLng> latLngList = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
    polylines.add(Polyline(
      polylineId: PolylineId('polyline'),
      color: Colors.red,
      width: 5,
      points: latLngList,
    ));
    setState(() {});
  }

  Future<void> displayPrediction(Prediction place,String value) async {
    if(place != null){
      setState(() {
        location = place.description.toString();
      });
      final plist = GoogleMapsPlaces(apiKey:googleApikey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      final geometry = detail.result.geometry!;
      final lat = geometry.location.lat;
      final lang = geometry.location.lng;
      var newLatLang = LatLng(lat, lang);
      print("place = ${place.description}");

      switch (value) {
        case 'source':
          sourceLocation = LatLng(lat, lang);
          print("sourceLocation = $sourceLocation");
          break;
        case 'destination':
          destination = LatLng(lat, lang);
          print("destination = $destination");
          break;
        default:
          print('沒選擇出發點或目的地');
      }

      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newLatLang, zoom: 17)));
    }
  }

  getCity() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    sourceLocation =
        LatLng(position!.latitude, position!.longitude); // 設定使用者目前位置
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: sourceLocation!, zoom: 17)));
  }

  current() async {
    var data = await Directions().geocode2Address(sourceLocation!.latitude.toString(), sourceLocation!.longitude.toString(),googleApikey);
    if (data['status'] == "OK") {
      _startPlace.text = data['results'][1]['formatted_address'];
      print(data['results'][1]['formatted_address']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    markers: markers,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: defaultLocation,
                      zoom: 14.0,
                    ),
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                    polylines: polylines,
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 100,
                    width: 300,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD7DDE9),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.all(8.0),child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: SizedBox()),
                            SizedBox(
                              width: 300,
                              height: 40,
                              child: TextField(
                                maxLines: 1,
                                textInputAction: TextInputAction.newline,
                                onTap: () async {
                                  Prediction? place = await PlacesAutocomplete.show(
                                      context: context,
                                      radius: 10000000,
                                      apiKey: googleApikey,
                                      mode: Mode.overlay,
                                      types: [],
                                      strictbounds: false,
                                      language: 'zh_tw',
                                      components: [
                                        Component(Component.country, "TW"),
                                      ],
                                      onError: (err){
                                        print("maps api ERROR:$err");
                                      }
                                  );
                                  displayPrediction(place!,"source");
                                  setState(() {
                                    _startPlace.text = place.description.toString();
                                  });
                                },
                                controller: _startPlace,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  hintText: '輸入出發點',
                                  hintStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4,),
                            SizedBox(
                              width: 300,
                              height: 40,
                              child: TextField(
                                maxLines: 1,
                                textInputAction: TextInputAction.newline,
                                onTap: () async {
                                  Prediction? place = await PlacesAutocomplete.show(
                                      context: context,
                                      radius: 10000000,
                                      apiKey: googleApikey,
                                      mode: Mode.overlay,
                                      types: [],
                                      strictbounds: false,
                                      language: 'zh_tw',
                                      components: [
                                        Component(Component.country, "TW"),
                                      ],
                                      onError: (err){
                                        print("maps api ERROR:$err");
                                      }
                                  );
                                  displayPrediction(place!,"destination");
                                  setState(() {
                                    _endPlace.text = place.description.toString();
                                  });
                                },
                                controller: _endPlace,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  hintText: '輸入目的地',
                                  hintStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                          ],
                        ),),
                      ],
                    )),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.00),
                        ),
                        minWidth: 30.0,
                        height: 40.0,
                        child: RaisedButton(
                          onPressed: () => {
                            addMarker(),
                          },
                          textColor: const Color(0xFF65542B),
                          color: const Color(0xFFFCEECB),
                          child: I18nText("roadplan.suggest"),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.00),
                        ),
                        minWidth: 30.0,
                        height: 40.0,
                        child: RaisedButton(
                          onPressed: () => {
                            getCity(),
                            current(),
                          },
                          textColor: const Color(0xFF000000),
                          color: const Color(0xFF8ABCF1),
                          child: I18nText("roadplan.current"),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.00),
                        ),
                        minWidth: 30.0,
                        height: 40.0,
                        child: RaisedButton(
                          onPressed: () => faster(),
                          textColor: const Color(0xFF65542B),
                          color: const Color(0xFFFCEECB),
                          child: I18nText("roadplan.faster"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}
