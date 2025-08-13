import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  const FilterButton(
      {super.key, required this.icon, required this.label, this.onPressed});

  final ImageIcon icon;
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          icon: icon,
          onPressed: onPressed,
          color: kWhite,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kWhite,
          ),
        ),
      ],
    );
  }
}
