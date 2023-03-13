import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions with ChangeNotifier {
  static String url = "https://maps.googleapis.com/maps/api/directions/json?";
  static String? _distance;
  static String? _duration;
  static List? _route;

  String get distance => "$_distance";
  String get duration => "$_duration";
  List? get route => _route;

  Future<dynamic> directions(LatLng origin, LatLng dest, String googleApikey) async {
    var dio = Dio();

    final response = await dio.get(url,queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${dest.latitude},${dest.longitude}',
      'key': googleApikey,
    });

    if (response.data['status'] == "OK")
    {
      print(response.data);
      return response.data;
    }
    else
    {
      return "導航錯誤";
    }
    notifyListeners();
  }

  Future<dynamic> geocode2Address(String lat, String lng, String googleApikey) async {
    var dio = Dio();
    String url = "https://maps.googleapis.com/maps/api/geocode/json?";
    final response = await dio.get(url,queryParameters: {
      'latlng': "$lat,$lng",
      'key': googleApikey,
    });
    return response.data;
  }
}