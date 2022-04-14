import 'dart:typed_data';
import 'package:automation/confirmation_dialog.dart';
import 'package:automation/views/buttons_view.dart';
import 'package:automation/views/console_view.dart';
import 'package:automation/utils/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutomationApp extends StatelessWidget {
  const AutomationApp({Key? key}) : super(key: key);

  Future<BluetoothDevice?> getDevice(BuildContext context) async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ListView(
          shrinkWrap: true,
          children: bondedDevices
              .map(
                (device) => ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(device.name ?? "<unknown>"),
                  subtitle: Text(device.address.toString()),
                  trailing: const Icon(Icons.link),
                  onTap: () {
                    Navigator.of(context).pop(device);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void connect(BuildContext context, {bool connectToLastDevice = false}) async {
    AppData appData = Provider.of<AppData>(context, listen: false);
    if (!appData.isEnabled) {
      appData.isEnabled =
          await FlutterBluetoothSerial.instance.requestEnable() ?? false;
      if (!appData.isEnabled) return;
    }
    if (appData.connection != null && appData.connection!.isConnected) {
      appData.connection!.dispose();
      appData.connection = null;
      appData.buttonText = 'CONNECT';
      await FlutterBluetoothSerial.instance.requestDisable();
      return;
    }
    BluetoothDevice? device;
    bool agree = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (connectToLastDevice) {
      final String? address = prefs.getString('deviceAddress');
      final String? name = prefs.getString('deviceName');
      if (address != null) {
        device = BluetoothDevice(address: address, name: name);
      }
      if (device != null) {
        agree = await showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
                'Connect to last device \'${device!.name??device.address}\'?'),
          ) ??
          false;
      }
    }
    if (device == null || !agree) {
      device = await getDevice(context);
    }
    if (device != null) {
      appData.buttonText = 'CONNECTING';
      BluetoothConnection.toAddress(device.address).then((connection) {
        appData.buttonText = 'DISCONNECT';
        appData.connection = connection;
        connection.input?.listen(
          (dataReceived) async {
            for (int byte in dataReceived) {
              String bin = byte.toRadixString(2).padLeft(8, '0');
              int n = int.parse(bin.substring(3, 6), radix: 2);
              if (bin.substring(0, 3) == '010' && bin[6] == '0') {
                appData.switchList[n].stateUpdate(bin[7] == '1', connection);
                appData.text =
                    '> Switch ${n + 1} turned ${bin[7] == '1' ? 'on' : 'off'}';
              }
            }
          },
        );
        connection.output.add(Uint8List.fromList('?'.codeUnits));
      });
      prefs.setString('deviceAddress', device.address);
      prefs.setString('deviceName', device.name ?? '<unknown>');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      builder: (context, _) {
        AppData data = Provider.of<AppData>(context, listen: false);
        if (data.connect) {
          connect(context, connectToLastDevice: true);
          data.connect = false;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Automation'),
            actions: [
              TextButton(
                child: Text(
                  context.watch<AppData>().buttonText,
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () => connect(context, connectToLastDevice: true),
                onLongPress: () => connect(context),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  !context.watch<AppData>().isEnabled
                      ? Icons.bluetooth_disabled
                      : context.watch<AppData>().isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth,
                ),
              ),
            ],
          ),
          body: Column(
            children: const [
              ConsoleView(),
              Expanded(child: ButtonsView()),
            ],
          ),
        );
      },
    );
  }
}
