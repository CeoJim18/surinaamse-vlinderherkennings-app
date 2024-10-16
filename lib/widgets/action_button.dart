import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressedFunction;
  final String buttonText;

  const ActionButton(
      {super.key, required this.onPressedFunction, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressedFunction,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          foregroundColor: Colors.black),
      child: Text(buttonText),
    );
  }
}
