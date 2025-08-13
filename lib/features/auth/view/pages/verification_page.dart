import 'package:fieldforce/utils/custom_field.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:flutter/material.dart' hide FlatButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const VerificationPage(),
      );
  const VerificationPage({super.key});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _idDocumentUrlController =
      TextEditingController();
  final TextEditingController _profileImageUrlController =
      TextEditingController();

  String _selectedRole = 'Rep';
  final List<String> _roles = ['Rep', 'Admin', 'Manager'];
  final _formKey = GlobalKey<FormState>();
  String? _profileImagePreviewUrl;

  @override
  void dispose() {
    _addressController.dispose();
    _idDocumentUrlController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  void _submitVerificationInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Get current user details to get the user ID
      final currentUserDetails = ref.read(currentUserDetailsProvider);

      currentUserDetails.when(
        data: (user) async {
          if (user != null) {
            final success = await ref
                .read(authControllerProvider.notifier)
                .updateUserProfile(
                  userId: user.id,
                  address: _addressController.text,
                  idDocumentUrl: _idDocumentUrlController.text,
                  profileImageUrl: _profileImageUrlController.text.isEmpty
                      ? ''
                      : _profileImageUrlController.text,
                  role: _selectedRole,
                  context: context,
                );

            // Navigate to dashboard only if update was successful
            if (mounted && success) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashBoardController()),
                (route) => false,
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: User not found. Please try again.'),
              ),
            );
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading user data...'),
            ),
          );
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
            ),
          );
        },
      );
    }
  }

  Widget _buildProfileImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _profileImageUrlController,
          hintText: 'Profile Image URL (Optional)',
          keyboardType: TextInputType.url,
          validator: (value) {
            // Profile image URL is optional
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.isAbsolute) {
                return 'Enter a valid URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _profileImagePreviewUrl = _profileImageUrlController.text;
                });
              },
              child: const Text('Preview'),
            ),
            const SizedBox(width: 16.0),
            _profileImagePreviewUrl != null &&
                    _profileImagePreviewUrl!.isNotEmpty
                ? Image.network(
                    _profileImagePreviewUrl!,
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Your account has been created successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please complete your profile information below to proceed with verification:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _addressController,
                hintText: 'Address',
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: _idDocumentUrlController,
                hintText: 'ID Document URL',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID Document URL is required for verification';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildProfileImagePicker(),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value ?? 'Rep';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Role is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              FlatButton(
                onTap: authState ? () {} : _submitVerificationInfo,
                buttonText:
                    authState ? 'Submitting...' : 'Submit for Verification',
              ),
              const SizedBox(height: 16.0),
              const Text(
                'After submitting, please wait for an administrator to verify your account.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
