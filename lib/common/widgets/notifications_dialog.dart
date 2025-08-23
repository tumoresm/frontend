import 'package:flutter/material.dart';
import 'package:fieldforce/features/notifications/view/pages/notification_center_page.dart';

/// @deprecated Use NotificationCenterPage directly instead of this dialog
class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the full notification center instead of showing a dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationCenterPage(),
        ),
      );
    });

    // Return empty container as we're navigating away
    return const SizedBox.shrink();
  }
}
