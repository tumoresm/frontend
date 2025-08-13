import 'package:fieldforce/common/widgets/assets_constants.dart';
import 'package:fieldforce/common/widgets/filter_button.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        height: 90,
        decoration: BoxDecoration(
            color: kEerieBlack, borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterButton(
                icon: const ImageIcon(AssetImage(AssetsConstants.telecom),
                    size: 20),
                label: 'Telecoms',
                onPressed: () {},
              ),
              FilterButton(
                icon: const ImageIcon(
                  AssetImage(AssetsConstants.energy),
                  size: 20,
                ),
                label: 'Energy',
                onPressed: () {},
              ),
              FilterButton(
                icon: const ImageIcon(
                  AssetImage(AssetsConstants.financial),
                  size: 20,
                ),
                label: 'Financial',
                onPressed: () {},
              ),
              FilterButton(
                icon:
                    const ImageIcon(AssetImage(AssetsConstants.more), size: 20),
                label: 'More',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
