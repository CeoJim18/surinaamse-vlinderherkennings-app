// screens/second_route.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/butterfly_information_data.dart';
import '../widgets/butterfly_information/butterfly_information_display.dart';

class ButterflyInformationPage extends StatefulWidget {
  final String vlinderSoort;

  const ButterflyInformationPage({super.key, required this.vlinderSoort});

  @override
  State<StatefulWidget> createState() {
    return _ButterflyInformationPageState();
  }
}

class _ButterflyInformationPageState extends State<ButterflyInformationPage> {
  @override
  Widget build(BuildContext context) {
    var vlinderSoortNaam = widget.vlinderSoort;

    final filteredButterflies = butterflyInformationData
        .where(
          (vlinder) => vlinder.scientificName == vlinderSoortNaam,
        )
        .toList();

    var vlinderSoortInformatie =
        filteredButterflies.isNotEmpty ? filteredButterflies.first : null;
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text('Butterfly Information'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            if (vlinderSoortInformatie == null)
              const Text(
                'No information yet',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              )
            else
              ButterflyInformationDisplay(
                  vlinderSoortInformatie: vlinderSoortInformatie),
          ],
        ),
      ),
    );
  }
}
