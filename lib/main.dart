import 'package:NTRoute/barcode.dart';
import 'package:NTRoute/bloc/barcode_bloc.dart';
import 'package:NTRoute/bloc/barcode_bloc_provider.dart';
import 'package:NTRoute/harita.dart';
import 'package:NTRoute/servis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Platform messages are asynchronous, so we initialize in an async method.
  BarcodeBloc _barcodeBloc;

  @override
  void initState() {
    super.initState();
    _barcodeBloc = BarcodeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:
            BarcodeBlocProvider(barcodeBloc: _barcodeBloc, child: HomePage()));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BarcodeBloc _barcodeBloc;
  String barcode;
  LocationServis servis = LocationServis();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _barcodeBloc = new BarcodeBloc();
    _barcodeBloc.barcodeStream.listen((barcode) {
      setState(() {
        _barcodeBloc.barkodListesi.add(barcode);
      });
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (_barcodeBloc.barkodListesi.contains(barcodeScanRes) ||
          barcodeScanRes.length != 9) return;
      barcode = barcodeScanRes;
      servis.sorguYap(barcode).then((value) => showAlertDialog(context, value));
    });
  }

  @override
  dispose() {
    _barcodeBloc.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context, Barkod barkod) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        _barcodeBloc.barcodeSink.add(barcode);
        scanBarcodeNormal();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(barkod.customerName),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode scan'),
      ),
      body: Stack(
        children: [
          ListView(
            children: List.generate(_barcodeBloc.barkodListesi.length,
                (index) => Text(_barcodeBloc.barkodListesi[index])),
          ),
          Positioned(
            bottom: 20,
            left: 50,
            child: RaisedButton(
              child: SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                    child: Text(
                      "Okut",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () => scanBarcodeNormal(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        onPressed: () {
          _barcodeBloc.rotaAl();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Harita()),
          );
        },
      ),
    );
  }
}
