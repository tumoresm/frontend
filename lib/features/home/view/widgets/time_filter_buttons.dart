import 'package:fieldforce/theme/theme.dart';
import 'package:flutter/material.dart';

class TimeFilterButtons extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const TimeFilterButtons({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Colours.selectedIndex.withOpacity(0.06)
              : Colours.transparentColor,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class TimeFilterRow extends StatefulWidget {
  const TimeFilterRow({super.key});

  @override
  State<TimeFilterRow> createState() => _TimeFilterRowState();
}

class _TimeFilterRowState extends State<TimeFilterRow> {
  String selectedPeriod = 'Week';
  final List<String> periods = ["Day", "Week", "Month", "Year"];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: periods.map((period) {
        return TimeFilterButtons(
            label: period,
            isSelected: selectedPeriod == period,
            onPressed: () => setState(() => selectedPeriod = period));
      }).toList(),
    );
  }
}
