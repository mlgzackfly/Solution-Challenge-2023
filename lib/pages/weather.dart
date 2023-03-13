import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:safego/model/api/fetch.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Position? position;
  String? city;
  double lat = 0.0;
  double lng = 0.0;

  initState() {
    getCity();
  }

  getCity() async {
    EasyLoading.show();
    position = await _determinePosition();
    lat = position!.latitude;
    lng = position!.longitude;
    debugPrint("LAT=${lat.toString()}");
    debugPrint("LNG=${lng.toString()}");
    await Provider.of<FetchWeather>(context, listen: false)
        .weatherByGraphQL(lng.toString(), lat.toString());
    await Provider.of<FetchWeather>(context, listen: false)
        .rainByGraphQL(lng.toString(), lat.toString());
    setState(
      () {
        city = Provider.of<FetchWeather>(context, listen: false).locationName;
      },
    );
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        EasyLoading.dismiss();
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 60,
                ),
                Container(
                  height: 120,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    border: Border.all(width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (city != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city!,
                                style: TextStyle(fontSize: 24),
                              ),
                              Center(
                                child: Text(
                                  Provider.of<FetchWeather>(context,
                                          listen: false)
                                      .weather,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (city != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                Provider.of<FetchWeather>(context,
                                        listen: false)
                                    .tempLate,
                                style: TextStyle(fontSize: 48),
                              ),
                              Text(
                                Provider.of<FetchWeather>(context,
                                        listen: false)
                                    .maxMinTemplate,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                I18nText(
                  "weather.WeatherForecastDescription",
                  child: const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    border: Border.all(width: 1.0),
                  ),
                  child: Center(
                    child: Text(
                      Provider.of<FetchWeather>(context, listen: false)
                          .description,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                I18nText(
                  "weather.alert",
                  child: const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    border: Border.all(width: 1.0),
                  ),
                  child: Center(
                    child: Text(
                      Provider.of<FetchWeather>(context, listen: false).alter,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                I18nText(
                  "weather.rainfall",
                  child: const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    // color: Color(0xFF0099FF),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    border: Border.all(width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox()),
                      const Icon(
                        Icons.water_drop,
                        size: 36,
                      ),
                      Text(
                        "${Provider.of<FetchWeather>(context, listen: false).rain} mm",
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
