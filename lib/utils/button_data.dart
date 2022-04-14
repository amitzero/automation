import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ButtonData with ChangeNotifier {
  ButtonData({required String name, required int index, required bool state})
      : _name = name,
        _index = index,
        _state = state;

  String _name;
  final int _index;
  bool _state;
  BluetoothConnection? _connection;

  bool get state => _state;

  void stateUpdate(bool value, BluetoothConnection connection) {
    _state = value;
    _connection = connection;
    notifyListeners();
  }

  set state(bool value) {
    if (_connection != null && _connection!.isConnected) {
      _state = value;
      _connection?.output.add(Uint8List.fromList('$_index'.codeUnits));
      if (kDebugMode) {
        print('Sending $_index to $_connection');
      }
      notifyListeners();
    }
  }

  String get name => '$_name ${_index + 1}';

  set name(String value) {
    _name = value;
    notifyListeners();
  }
}
