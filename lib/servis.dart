import 'package:NTRoute/barcode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationServis {
  LatLng lng;

  Future<Barkod> sorguYap(String barcode) async {
    final String url =
        "http://89.107.230.18:13250/api/Route/Getlocation?barcode=$barcode";

    final response = await http.get(url);
    final int status = response.statusCode;

    if (status == 200 || status == 201) {
      Barkod barkod = Barkod.fromJson(jsonDecode(response.body));

      // lat.add(enlem.toString());
      // lng.add(boylam.toString());
      return barkod;
    }
  }

  Future<List<Barkod>> sorguYapRandom() async {
    final String url =
        "http://89.107.230.18:13250/api/Route/GetRandomlocations";

    final response = await http.get(url);
    final int status = response.statusCode;

    if (status == 200 || status == 201) {
      List responseJson = json.decode(response.body);
      List<Barkod> liste =
          responseJson.map((m) => new Barkod.fromJson(m)).toList();
      return liste;
    }
  }
}
