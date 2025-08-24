import 'package:fieldforce/utils/custom_field.dart';
import 'package:fieldforce/utils/flat_button.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/home/controller/dashboard_controller.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final TextEditingController _idNumberController = TextEditingController();

  String _selectedRole = 'Rep';
  final List<String> _roles = ['Rep', 'Admin', 'Manager'];
  final _formKey = GlobalKey<FormState>();
  File? _profileImageFile;
  bool _isCheckingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  /// Check if user has already completed their profile
  void _checkExistingProfile() async {
    try {
      final userDetails = await ref.read(currentUserDetailsProvider.future);
      
      if (userDetails != null) {
        // Pre-fill form with existing data
        if (userDetails.address.isNotEmpty) {
          _addressController.text = userDetails.address;
        }
        if (userDetails.idNumber != null && userDetails.idNumber!.isNotEmpty) {
          _idNumberController.text = userDetails.idNumber!;
        }
        if (userDetails.role.isNotEmpty) {
          _selectedRole = userDetails.role;
        }
        
        // Check if profile is already complete
        final isComplete = await ref.read(isProfileCompleteProvider.future);
        if (isComplete) {
          Loggers.auth.info('Profile already complete, navigating to dashboard');
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const DashBoardController(),
              ),
              (route) => false,
            );
            return;
          }
        }
      }
    } catch (e) {
      Loggers.auth.error('Error checking existing profile', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImageFile = File(image.path);
      });
    }
  }

  void _skipVerification() {
    Loggers.auth.info('User chose to skip verification');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Verification'),
        content: const Text(
          'You can complete your profile verification later from the settings page. '
          'Some features may be limited until your profile is verified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashBoardController(),
                ),
                (route) => false,
              );
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
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
                  idNumber: _idNumberController.text,
                  profileImage: _profileImageFile, // Pass the File object
                  role: _selectedRole,
                  verificationStatus: 'Pending',
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
        // Display selected image or placeholder
        Center(
          child: _profileImageFile != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_profileImageFile!),
                )
              : CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, size: 50, color: Colors.grey.shade400),
                ),
        ),
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton.icon(
            onPressed: _pickProfileImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Pick Profile Image'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Show loading while checking existing profile
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking profile status...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: _skipVerification,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
                controller: _idNumberController,
                hintText: 'ID Number',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID Number is required for verification';
                  }
                  if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                    return 'ID Number must be a 13-digit number';
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
              OutlinedButton(
                onPressed: _skipVerification,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  'Skip for Now',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'After submitting, please wait for an administrator to verify your account.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'You can complete verification later from your profile settings.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}