import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileMenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool endIcon;

  const ProfileMenuButton({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
    this.endIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(180),
          color: kEerieBlack.withOpacity(0.1),
        ),
        child: Icon(icon, color: kPrimary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colours.cardColor,
        ),
        child: const Icon(
          Symbols.keyboard_arrow_right,
          color: kPrimary,
        ),
      ),
    );
  }
}
