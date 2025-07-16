import 'package:fieldforce/theme/theme.dart';
import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  const FlatButton({super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colours.gradient1,
            Colours.gradient2,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(100, 55),
          backgroundColor: Colours.transparentColor,
          shadowColor: Colours.transparentColor,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
