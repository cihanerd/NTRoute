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
    return BarcodeBlocProvider(
        barcodeBloc: _barcodeBloc,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ));
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
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _barcodeBloc = BarcodeBlocProvider.of(context).barcodeBloc;
    _barcodeBloc.verileriGetir();
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
    if (_barcodeBloc.barkodListesi.contains(barcodeScanRes) ||
        barcodeScanRes.length != 9) {
      showAlertDialogHata(context);
      return;
    }
    setState(() {
      barcode = barcodeScanRes;
      servis.sorguYap(barcode).then((value) => showAlertDialog(context, value));
    });
  }

  @override
  dispose() {
    _barcodeBloc.dispose();
    super.dispose();
  }

  showAlertDialogHata(BuildContext context) {
    Widget kapatButon = FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Kapat"));

    AlertDialog alert = AlertDialog(
      title: Text("Hata!"),
      content:
          Text("Barkod daha önce kaydedilmiş veya okunurken bir hata oluştu!"),
      actions: [kapatButon],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context, Barkod barkod) {
    // setState(() {});
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("İptal"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yeni Barkod Ekle"),
      onPressed: () {
        _barcodeBloc.barcodeSink.add(barcode);
        scanBarcodeNormal();
        Navigator.pop(context);
      },
    );
    Widget kaydetKapat = FlatButton(
      child: Text("Kaydet & Kapat"),
      onPressed: () {
        _barcodeBloc.barcodeSink.add(barcode);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(barkod.customerName),
      actions: [continueButton, cancelButton, kaydetKapat],
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
        title: const Text('NT Route'),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _barcodeBloc.barkodStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: List.generate(
                      snapshot.data.length,
                      (index) => ExpansionTile(
                            expandedAlignment: Alignment.centerLeft,
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(
                                        snapshot.data[index].customerName)),
                                IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _barcodeBloc.sil(index);
                                    })
                              ],
                            ),
                            children: [
                              Text(
                                snapshot.data[index].customerAddress
                                    .toString()
                                    .trim(),
                              ),
                              Text(
                                snapshot.data[index].customerPhone,
                              ),
                              Text(
                                snapshot.data[index].latitude.toString(),
                              ),
                              Text(
                                snapshot.data[index].longitude.toString(),
                              ),
                            ],
                          )),
                );
              } else
                return Center(
                  child: CircularProgressIndicator(),
                );
            },
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
                      "Yeniden Getir",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () => _barcodeBloc.verileriGetir(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        onPressed: () {
          _barcodeBloc.rotaAl();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Harita()),
          );
        },
      ),
    );
  }
}
