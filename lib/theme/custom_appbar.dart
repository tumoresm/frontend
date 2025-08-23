import 'package:fieldforce/common/widgets/assets_constants.dart';
import 'package:fieldforce/common/widgets/notifications_dialog.dart';
import 'package:fieldforce/features/notifications/view/widgets/notification_badge.dart';
import 'package:fieldforce/features/notifications/view/pages/notification_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAppBar {
  static AppBar appBar(BuildContext context, Widget navtitle) {
    final appbarlogo = SvgPicture.asset(
      AssetsConstants.salesTrackerLogo,
      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      height: 35,
    );
    return AppBar(
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: appbarlogo,
      ),
      title: navtitle,
      centerTitle: true,
      actions: [
        NotificationBadge(
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationCenterPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
