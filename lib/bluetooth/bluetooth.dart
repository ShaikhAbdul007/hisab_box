import 'package:flutter_blue_plus/flutter_blue_plus.dart';

mixin class CommonBluetooth {
  Future<bool> checkBluetoothConnectivity() async {
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      return true;
    } else {
      return false;
    }
  }
}
