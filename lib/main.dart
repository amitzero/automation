import 'package:automation/views/automation_app.dart';
import 'package:automation/views/confirmation_dialog.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AutomationApp()));

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0)).then(
      (value) async {
        bool result = await showDialog(
              context: context,
              builder: (context) =>
                  const ConfirmationDialog('Connect to last device \'AMIT\''),
            ) ??
            false;
        print('$result');
      },
    );
    return const Scaffold(
      body: Center(
        child: Text('Hello There'),
      ),
    );
  }
}
