import 'package:flutter/material.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement skip logic
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number',
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
            ),
            const SizedBox(height: 16.0),
            // TODO: Add role dropdown (defaulted to 'Rep')
            // TODO: Add profile image picker
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement profile update logic
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
