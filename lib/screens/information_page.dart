// screens/second_route.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final String vlinderSoort;
  const InformationPage({super.key, required this.vlinderSoort});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CupertinoNavigationBar(
          middle: Text('Second Route'),
        ),
        body: Center(
            child: Column(
          children: [
            Text(vlinderSoort,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ],
        )));
  }
}
