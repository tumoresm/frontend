import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'assets_constants.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.salesTrackerLogo,
        color: Colors.red[600],
        height: 35,
      ),
      centerTitle: true,
    );
  }
}
