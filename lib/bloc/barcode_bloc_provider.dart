import 'package:NTRoute/bloc/barcode_bloc.dart';
import 'package:flutter/cupertino.dart';

class BarcodeBlocProvider extends InheritedWidget {
  final BarcodeBloc barcodeBloc;
  const BarcodeBlocProvider({Key key, Widget child, this.barcodeBloc})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(BarcodeBlocProvider old) {
    return (barcodeBloc != old.barcodeBloc);
  }

  static BarcodeBlocProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }
}
