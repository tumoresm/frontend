import 'package:fieldforce/common/widgets/profile_menu.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/auth/view/pages/verification_page.dart';
import 'package:fieldforce/constants/verification_constants.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:fieldforce/utils/loading_page.dart';
import 'package:flutter/material.dart' hide FlatButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserDetails = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: currentUserDetails.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('User not found.'));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null, // Placeholder for default image
                      child: user.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        user.verificationStatus == VerificationStatus.verified
                            ? Symbols.verified
                            : Symbols.verified_off,
                        color: user.verificationStatus == VerificationStatus.verified
                            ? Colors.blue
                            : Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  Text(user.email),
                  Text(user.phoneNumber),
                  Text(user.role),
                  const SizedBox(height: 15),
                  // Show 'Get Verified' button only for unverified users
                  if (user.verificationStatus != VerificationStatus.verified)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerificationPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.verificationStatus == VerificationStatus.pending
                            ? Colors.orange
                            : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        user.verificationStatus == VerificationStatus.pending
                            ? 'Update Verification Info'
                            : 'Get Verified',
                      ),
                    ),
                  // Show verification status for verified users
                  if (user.verificationStatus == VerificationStatus.verified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Verified Account',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Divider(),
                  //Menu ListTiles
                  const ProfileMenuButton(
                      title: 'Settings', icon: Symbols.settings),
                  const ProfileMenuButton(
                      title: 'Security', icon: Symbols.security),
                  const ProfileMenuButton(
                      title: 'Legal Terms', icon: Symbols.contract_edit),
                  const ProfileMenuButton(title: 'Help', icon: Symbols.help),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  FlatButton(
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout(context);
                    },
                    buttonText: 'Logout',
                  ),
                  // You can add more user details here
                ],
              ),
            );
          },
          loading: () => const Loader(),
          error: (error, stack) =>
              Center(child: Text('Error: ${error.toString()}')),
        ),
      ),
    );
  }
}
