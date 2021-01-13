import 'package:NTRoute/bloc/barcode_bloc.dart';
import 'package:NTRoute/bloc/barcode_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class Harita extends StatefulWidget {
  @override
  _HaritaState createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {
  BarcodeBloc _barcodeBloc;
  List<Marker> markerlar = [];
  double baslaLat, baslaLong;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _barcodeBloc = BarcodeBlocProvider.of(context).barcodeBloc;
  }

  @override
  dispose() {
    super.dispose();
  }

  konumBul() async {
    await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.high)
        .then((value) {
      baslaLat = value.latitude;
      baslaLong = value.longitude;
    });
    return true;
  }

  List<Polyline> polylines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Harita"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Stack(
          children: [
            FutureBuilder(
                future: konumBul(),
                builder: (BuildContext contex, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return StreamBuilder(
                      stream: _barcodeBloc.rotaStream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          polylines.add(Polyline(
                              polylineId: PolylineId("poly"),
                              width: 6,
                              color: Colors.blue.shade700,
                              geodesic: true,
                              points: snapshot.data));
                          markerlar = List.generate(
                              _barcodeBloc.koordinatListesi.length,
                              (index) => Marker(
                                  markerId: MarkerId(index.toString()),
                                  position:
                                      _barcodeBloc.koordinatListesi[index],
                                  infoWindow: InfoWindow(
                                      title: _barcodeBloc
                                          .barkodList[index].customerName)));

                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(baslaLat, baslaLong), zoom: 16),
                            polylines: Set<Polyline>.of(polylines),
                            onMapCreated: (controller) {},
                            markers: Set<Marker>.of(markerlar),
                            myLocationEnabled: true,
                          );
                        } else {
                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(baslaLat, baslaLong), zoom: 16),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ));
  }
}
