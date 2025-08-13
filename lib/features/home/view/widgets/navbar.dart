import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  const HomeNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: Colours.backgroundColor,
      indicatorColor: Colours.transparentColor,
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.home,
            fill: 1,
            color: kPrimary,
          ),
          icon: Icon(
            Symbols.home,
            size: 30,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.package_2,
            fill: 1,
            color: kPrimary,
          ),
          icon: Icon(
            Symbols.package_2,
            size: 30,
          ),
          label: 'Orders',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.wallet,
            fill: 1,
            color: kPrimary,
          ),
          icon: Icon(
            Symbols.wallet,
            size: 30,
          ),
          label: 'Wallet',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.manage_accounts,
            fill: 1,
            color: kPrimary,
          ),
          icon: Icon(
            Symbols.manage_accounts,
            size: 30,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
