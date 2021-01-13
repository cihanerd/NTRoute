import 'dart:async';

import 'package:NTRoute/servis.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as direction;
import 'package:geolocator/geolocator.dart' as geo;

class BarcodeBloc {
  direction.GoogleMapsDirections directions = direction.GoogleMapsDirections(
      apiKey: "AIzaSyC2TRVqnMgCx5b2pFm3Cn88io8lsp6NGu4");
  List<String> barkodListesi = new List<String>();
  List<LatLng> koordinatListesi = new List<LatLng>();
  LocationServis servis = new LocationServis();
  StreamController<String> barcodeStreamController =
      new StreamController<String>.broadcast();
  Stream<String> get barcodeStream => barcodeStreamController.stream;
  Sink<String> get barcodeSink => barcodeStreamController.sink;

  StreamController<List<LatLng>> rotaStreamController =
      new StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get rotaStream => rotaStreamController.stream;
  Sink<List<LatLng>> get rotaSink => rotaStreamController.sink;

  BarcodeBloc() {
    barcodeStream.listen((event) {
      servis.sorguYap(event).then((value) =>
          koordinatListesi.add(new LatLng(value.latitude, value.longitude)));
    });
  }
  dispose() {
    barcodeStreamController.close();
    rotaStreamController.close();
  }

  Future<geo.Position> konumIste() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);

    return position;
  }

  List<direction.Waypoint> waypointListe = List<direction.Waypoint>();
  void rotaAl() {
    for (var i = 0; i < koordinatListesi.length; i++) {
      direction.Waypoint waypoint = direction.Waypoint.fromLocation(
          direction.Location(
              koordinatListesi[i].latitude, koordinatListesi[i].longitude));
      waypointListe.add(waypoint);
    }
    konumIste().then((geo.Position value) {
      directions
          .directionsWithLocation(
            direction.Location(value.latitude, value.longitude),
            direction.Location(
                koordinatListesi[koordinatListesi.length - 1].latitude,
                koordinatListesi[koordinatListesi.length - 1].longitude),
            waypoints: waypointListe,
          )
          .then((value) => _polyLineCiz(value));
    });
  }

  void _polyLineCiz(direction.DirectionsResponse value) {
    List<LatLng> keskinNoktalar = List<LatLng>();

    for (var i = 0; i < waypointListe.length; i++) {
      for (var item in value.routes[0].legs[i].steps) {
        keskinNoktalar.addAll(decodeEncodedPolyline(item.polyline.points));
      }
    }
    rotaSink.add(keskinNoktalar);
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
