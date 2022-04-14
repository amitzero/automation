
import 'package:automation/utils/button_data.dart';
import 'package:automation/utils/app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonsView extends StatelessWidget {
  const ButtonsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppData data = Provider.of<AppData>(context);
    return Stack(
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          children: [
            for (int i = 0; i < data.switchList.length; i++)
              ChangeNotifierProvider<ButtonData>.value(
                value: data.switchList[i],
                child: const ButtonView(),
              ),
          ],
        ),
        if (data.connection == null || !data.connection!.isConnected)
          Container(
            alignment: Alignment.center,
            color: Colors.black45,
            child: const Text(
              'Not Connected',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class ButtonView extends StatelessWidget {
  const ButtonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ButtonData>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lightbulb,
          size: 80,
          color: data.state ? Colors.yellow : Colors.grey,
        ),
        CupertinoSwitch(
          value: data.state,
          onChanged: (value) {
            data.state = value;
          },
        ),
        Text(data.name),
      ],
    );
  }
}
