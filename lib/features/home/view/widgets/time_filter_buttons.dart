import 'package:fieldforce/features/home/provider/time_filter_provider.dart';
import 'package:fieldforce/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected
              ? Colours.selectedIndex.withOpacity(0.15)
              : Colours.transparentColor,
          border: Border.all(
            color: isSelected
                ? Colours.selectedIndex
                : Colours.greyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colours.selectedIndex : Colours.greyColor,
          ),
        ),
      ),
    );
  }
}

class TimeFilterRow extends ConsumerWidget {
  const TimeFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(timeFilterProvider);
    const periods = TimeFilterPeriod.values;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: periods.map((period) {
          return Expanded(
            child: TimeFilterButtons(
              label: period.displayName,
              isSelected: selectedPeriod == period,
              onPressed: () {
                ref.read(timeFilterProvider.notifier).setPeriod(period);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
