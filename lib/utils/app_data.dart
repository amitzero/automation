import 'package:automation/utils/button_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AppData with ChangeNotifier {
  AppData({String name = "Switch", bool state = false})
      : _switch = List.generate(8, (index) {
          return ButtonData(name: name, index: index, state: state);
        }) {
    FlutterBluetoothSerial.instance.isEnabled.then((enabled) {
      isEnabled = enabled ?? false;
    });
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      isEnabled = state.isEnabled;
      connection = null;
      buttonText = 'CONNECT';
    });
  }

  bool connect = true;

  BluetoothConnection? _connection;

  final List<String> _consoleText = List.empty(growable: true);

  final List<ButtonData> _switch;

  bool _isEnabled = false;

  String _buttonText = 'CONNECT';

  set connection(BluetoothConnection? connection) {
    _connection = connection;
    notifyListeners();
  }

  BluetoothConnection? get connection => _connection;

  bool get isConnected => _connection != null && _connection!.isConnected;

  List<ButtonData> get switchList => _switch;

  String get text => _consoleText.isEmpty ? '' : _consoleText.join('\n');

  set text(String value) {
    _consoleText.add(value);
    if (_consoleText.length > 8) {
      _consoleText.removeAt(0);
    }
    notifyListeners();
  }

  bool get isEnabled => _isEnabled;

  set isEnabled(bool value) {
    _isEnabled = value;
    notifyListeners();
  }

  String get buttonText => _buttonText;

  set buttonText(String value) {
    _buttonText = value;
    notifyListeners();
  }
}
