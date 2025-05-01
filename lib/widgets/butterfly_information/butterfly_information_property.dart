import 'package:flutter/material.dart';

class ButterflyInformationProperty extends StatelessWidget {
  final String attributeName;

  final String attributeValue;


  const ButterflyInformationProperty({super.key, required this.attributeName, required this.attributeValue});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
         Text(attributeName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(attributeValue,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }


}