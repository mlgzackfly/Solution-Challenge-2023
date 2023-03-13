import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

var dio = Dio();

void main() async {
  FetchTrafficNews().news();
}

class FetchTrafficNews with ChangeNotifier {
  static String? _title;

  String get firstNews {
    return "$_title";
  }


  Future<dynamic> news() async {
    var dio = Dio();

    final response = await dio.get("https://168.motc.gov.tw/opendata/json/news");
    _title = response.data[0]["Title"];

    notifyListeners();
    return response.data;
  }
}

class FetchRoadNews with ChangeNotifier {
  static String url = "https://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx?DATA=36384FA8-FACF-432E-BB5B-5F015E7BC1BE";

  static String? _region; //(路況區域)
  static String? _srcDetail; // (資料來源)
  static String? _areaNm; // (地區區分說明)
  static String? _uid; // (唯一編號)
  static String? _direction; // (方向)
  static String? _y1; // (緯度)
  static String? _happenTime; // (發生時間)
  static String? _roadType; // (路況類別)
  static String? _road; // (道路名稱)
  static String? _modDTtm; // (修改時間)
  static String? _comment; // (路況說明)
  static String? _happenDate; // (發生時間)
  static String? _x1; // (經度)
  static String? _firstComment;

  String? get region => _region; 
  String? get srcDetail => _srcDetail; 
  String? get areaNm => _areaNm; 
  String? get uid => _uid; 
  String? get direction => _direction; 
  String? get y1 => _y1; 
  String? get happenTime => _happenTime; 
  String? get roadType => _roadType; 
  String? get road => _road; 
  String? get modDttm => _modDTtm;
  String? get comment => _comment; 
  String? get happenDate => _happenDate; 
  String? get x1 => _x1;
  String? get firstComment => _firstComment;
  

  Future<dynamic> roadNews() async {
    var dio = Dio();
    final response = await dio.get(url);
    _firstComment =response.data[0]['comment'];
    return response.data;
  }

}

class FetchAttrations with ChangeNotifier {
  var dio = Dio();
  String attUrl = "https://soa.tainan.gov.tw/Api/Service/Get/b296a4c7-4406-4bc0-83c2-dab1a698802d";
  Future<dynamic> fetch () async{
    try {
      final response = await dio.get(attUrl);
      print(response);
      return response.data;
    } catch (DioError) {
      return "ERROR";
    }
  }

  Future<dynamic> fetchTP () async {
    var dio = Dio();
    String URL = "https://quality.data.gov.tw/dq_download_json.php?nid=121624&md5_url=d68117332878c6f2a498bfb3e1edffcb";
    final response = await dio.get(URL);
    print(response);
  }
}

class Member with ChangeNotifier {
  static bool isLogin = false;
  bool get login {
    return isLogin;
  }
}

class FetchWeather with ChangeNotifier {
  static String cityName ="臺北市";
  static String? _minTemplate;
  static String? _maxTemplate;
  static String? _template;
  static String? _weather;
  static String? _graphQLResponse;
  static String? _rain;
  static String? _locationName;
  static String? _description;

  String _alert = "現在很安全，沒有警報";
  String weatherURL =
      "https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86&format=JSON&locationName=$cityName";
  String stationURL = "https://opendata.cwb.gov.tw/api/v1/rest/datastore/C-B0074-002?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86&status=%E7%8F%BE%E5%AD%98%E6%B8%AC%E7%AB%99";
  String get maxMinTemplate {
    return "$_minTemplate°C / $_maxTemplate°C";
  }

  String get weather {
    return "$_weather";
  }


  String get alter {
    return _alert;
  }

  Future<dynamic> getAlert() async {
    final response = await dio.get("https://opendata.cwb.gov.tw/api/v1/rest/datastore/W-C0033-001?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86&locationName=$cityName&format=JSON");
    if (response.statusCode == 200) {
      print(response.data);
      _alert = response.data['records']['location'][0]['hazardConditions']['hazards'];
      notifyListeners();
    } else {
      print("資料抓取失敗");
    }
    return await response.data;
  }

  String get graphResponse {
    return "$_graphQLResponse";
  }

  String get tempLate {
    return "$_template°C";
  }

  String get rain {
    if (_rain == null) {
      return "0";
    }
    else {
      return "$_rain";
    }
  }

  String get locationName {
    return "$_locationName";
  }

  String get description {
    return _description ?? "";
  }

  Future<dynamic> weatherByGraphQL(String lng, String lat) async {
    var weatherGraphSQL = '''
    query town {
  town (longitude: $lng, latitude: $lat) {
    ctyCode,
    ctyName,
    townCode,
    townName,
    villageCode,
    villageName,
    forecast72hr {
      locationName,
      locationID,
      latitude,
      longitude,
      AT {
        description,
        timePeriods { #不指定的話會全撈出，或是可指定前幾筆 (first: N)
          dataTime,
          apparentTemperature,
          measures
        }
      },
      CI {
        description,
        timePeriods {
          dataTime,
          comfortIndex,
          measures
        }
      },
      #PoP12h,
      PoP6h {
        description,
        timePeriods {
          startTime,
          endTime,
          probabilityOfPrecipitation,
          measures
        }
      },
      #RH,
      T {
        timePeriods {
          dataTime,
          temperature,
          measures
        }
      },
      #Td,
      #WD,
      WeatherDescription {
        description
        timePeriods {
          startTime,
          endTime,
          weatherDescription,
          measures
        }
      },
      #WS,
      Wx {
        description,
        timePeriods {
          startTime,
          endTime,
          weather,
          weatherIcon,
          measures
        }
      }
    },
    forecastWeekday {
      locationName,
      locationID,
      latitude,
      longitude,
      #MinAT,
      #MaxAT,
      #MinCI,
      #MaxCI,
      PoP12h {
        description,
        timePeriods {
          startTime,
          endTime,
          probabilityOfPrecipitation,
          measures
        }
      },
      #RH,
      T {
        description,
        timePeriods {
          startTime,
          endTime,
          temperature,
          measures
        }
      },
      MinT {
        description,
        timePeriods {
          startTime,
          endTime,
          temperature,
          measures
        }
      },
      MaxT {
        description,
        timePeriods {
          startTime,
          endTime,
          temperature,
          measures
        }
      },
      #Td,
      UVI {
        description,
        timePeriods {
          startTime,
          endTime,
          UVIndex,
          UVIDescription,
          measures
        }
      },
      #WD,
      WeatherDescription {
        description
        timePeriods {
          startTime,
          endTime,
          weatherDescription,
          measures
        }
      },
      #WS,
      Wx {
        description,
        timePeriods {
          startTime,
          endTime,
          weather,
          weatherIcon,
          measures
        }
      }
    },
    #aqi,
    #station
  }
}
  ''';
    final graphQLResponse = await Dio().post("https://opendata.cwb.gov.tw/linked/graphql?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86",
      data: json.encode({
        "query": weatherGraphSQL
      }),
    );
    // print(graphQLResponse.data);
    Map<String, dynamic> _graphQLMap = graphQLResponse.data;

    _locationName = _graphQLMap['data']['town']['forecastWeekday']['locationName'];
    _template = _graphQLMap['data']['town']['forecastWeekday']['T']['timePeriods'][0]['temperature'];
    _minTemplate = _graphQLMap['data']['town']['forecastWeekday']['MinT']['timePeriods'][0]['temperature'];
    _maxTemplate = _graphQLMap['data']['town']['forecastWeekday']['MaxT']['timePeriods'][0]['temperature'];
    _weather = _graphQLMap['data']['town']['forecastWeekday']['Wx']['timePeriods'][0]['weather'];
    _description = _graphQLMap['data']['town']['forecastWeekday']['WeatherDescription']['timePeriods'][0]['weatherDescription'];
    notifyListeners();
  }


  Future<dynamic> rainByGraphQL(String lng, String lat) async {
    var rainGraphSQL = '''
    query aqi {
  aqi(longitude: $lng, latitude: $lat) {
    sitename,
    county,
    station {
      stationId,
      locationName,
      latitude,
      longitude,
      time {
        obsTime
      },
  }
}
}
  ''';
    String? stationID;
    final graphQLResponse = await Dio().post("https://opendata.cwb.gov.tw/linked/graphql?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86",
      data: json.encode({
        "query": rainGraphSQL
      }),
    );
    // print(graphQLResponse.data);
    Map<String, dynamic> _graphQLMap = graphQLResponse.data;

    // print(_graphQLMap['data']['aqi']);

    FetchWeather.cityName = _graphQLMap['data']['aqi'][0]['sitename'];
    stationID = _graphQLMap['data']['aqi'][0]['station']['stationId'];

    _graphQLResponse = graphQLResponse.data.toString();

    var rainUrl = "https://opendata.cwb.gov.tw/api/v1/rest/datastore/C-B0025-001?Authorization=CWB-36E7629B-8D46-4BE5-A7C6-655E63938D86&StationID=$stationID";

    final rainResponse = await dio.get(rainUrl);

    if (rainResponse.data['success'] == "true")
      {
        if (rainResponse.data['records']['location'].length != 0) {
          _rain = rainResponse.data['records']['location'].first;
        }
      }
    notifyListeners();

    print("==*=="*10);
    print("${rainResponse}");
  }


}

class HereRoutingAPI with ChangeNotifier {
  String secretKeyID = 'jBbGsD-7psalQwiB6z9cXg';
  String secrecKey =
      'qDb07HALkZ_RBZAqYMv1HbhbkmGjFQ--W0U6I3QptnHPsg_bL9miMV4HXOVVF12UPWyX5goUTM30IMkIVqbJ4w';
}

class FetchNews with ChangeNotifier {
  String APIkey = "88beb07503e54df194c233f58fabfb0a";

}