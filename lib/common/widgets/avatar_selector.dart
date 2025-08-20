import 'package:avatar_plus/avatar_plus.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AvatarSelector extends StatefulWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;
  final double size;

  const AvatarSelector({
    super.key,
    this.selectedAvatar,
    required this.onAvatarSelected,
    this.size = 80,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.selectedAvatar;
  }

  // Predefined avatar options using different avatar seeds
  final List<Map<String, dynamic>> _avatarOptions = [
    {'id': 'adventurer_1', 'seed': 'John'},
    {'id': 'adventurer_2', 'seed': 'Jane'},
    {'id': 'adventurer_3', 'seed': 'Alex'},
    {'id': 'adventurer_4', 'seed': 'Sam'},
    {'id': 'bottts_1', 'seed': 'Robot1'},
    {'id': 'bottts_2', 'seed': 'Robot2'},
    {'id': 'bottts_3', 'seed': 'Robot3'},
    {'id': 'bottts_4', 'seed': 'Robot4'},
    {'id': 'personas_1', 'seed': 'Person1'},
    {'id': 'personas_2', 'seed': 'Person2'},
    {'id': 'personas_3', 'seed': 'Person3'},
    {'id': 'personas_4', 'seed': 'Person4'},
  ];

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colours.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colours.whiteColor,
                ),
              ),
            ),
            // Avatar grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final avatar = _avatarOptions[index];
                  final isSelected = _selectedAvatar == avatar['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatar = avatar['id'];
                      });
                      widget.onAvatarSelected(avatar['id']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colours.gradient2 : Colors.grey[600]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colours.gradient2.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: AvatarPlus(
                          avatar['seed'],
                          height: widget.size,
                          width: widget.size,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAvatar() {
    if (_selectedAvatar == null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colours.cardColor,
          borderRadius: BorderRadius.circular(widget.size / 2),
          border: Border.all(color: Colors.grey[600]!, width: 2),
        ),
        child: Icon(
          Symbols.person,
          size: widget.size * 0.6,
          color: Colors.grey[400],
        ),
      );
    }

    // Find the selected avatar configuration
    final avatarConfig = _avatarOptions.firstWhere(
      (avatar) => avatar['id'] == _selectedAvatar,
      orElse: () => _avatarOptions[0],
    );

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size / 2),
        border: Border.all(color: Colours.gradient2, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((widget.size / 2) - 2),
        child: AvatarPlus(
          avatarConfig['seed'],
          height: widget.size,
          width: widget.size,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showAvatarPicker,
          child: Stack(
            children: [
              _buildSelectedAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colours.gradient2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colours.backgroundColor, width: 2),
                  ),
                  child: const Icon(
                    Symbols.edit,
                    size: 16,
                    color: Colours.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedAvatar == null ? 'Tap to select avatar' : 'Tap to change avatar',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

// Helper function to get avatar widget from avatar ID
Widget getAvatarFromId(String? avatarId, {double size = 50}) {
  if (avatarId == null) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colours.cardColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Symbols.person,
        size: size * 0.6,
        color: Colors.grey[400],
      ),
    );
  }

  // Predefined avatar configurations (same as in AvatarSelector)
  final Map<String, Map<String, dynamic>> avatarConfigs = {
    'adventurer_1': {'seed': 'John'},
    'adventurer_2': {'seed': 'Jane'},
    'adventurer_3': {'seed': 'Alex'},
    'adventurer_4': {'seed': 'Sam'},
    'bottts_1': {'seed': 'Robot1'},
    'bottts_2': {'seed': 'Robot2'},
    'bottts_3': {'seed': 'Robot3'},
    'bottts_4': {'seed': 'Robot4'},
    'personas_1': {'seed': 'Person1'},
    'personas_2': {'seed': 'Person2'},
    'personas_3': {'seed': 'Person3'},
    'personas_4': {'seed': 'Person4'},
  };

  final config = avatarConfigs[avatarId];
  if (config == null) {
    // Fallback to default icon if avatar ID is not found
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colours.cardColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Symbols.person,
        size: size * 0.6,
        color: Colors.grey[400],
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(size / 2),
    child: AvatarPlus(
      config['seed'],
      height: size,
      width: size,
    ),
  );
}