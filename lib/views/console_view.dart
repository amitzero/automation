import 'package:automation/utils/app_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsoleView extends StatelessWidget {
  const ConsoleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.black12,
      child: Text(
        context.watch<AppData>().text,
        style: TextStyle(color: Colors.green.shade800),
      ),
    );
  }
}
