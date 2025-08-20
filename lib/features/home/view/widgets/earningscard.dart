import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';

class EarningsCard extends StatelessWidget {
  final double? totalEarnings;
  final double? totalPaid;
  final bool isLoading;

  const EarningsCard({
    super.key,
    this.totalEarnings,
    this.totalPaid,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    
    // Responsive dimensions
    final cardHeight = isSmallScreen ? 90.h : isMediumScreen ? 100.h : 110.h;
    final horizontalPadding = isSmallScreen ? 12.w : 16.w;
    final verticalPadding = isSmallScreen ? 8.h : 12.h;
    final iconSize = isSmallScreen ? 18.sp : 20.sp;
    final titleFontSize = isSmallScreen ? 12.sp : 14.sp;
    final amountFontSize = isSmallScreen ? 14.sp : 16.sp;
    
    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [
            Colours.gradient1,
            Colours.gradient2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: _buildContent(
          horizontalPadding,
          verticalPadding,
          iconSize,
          titleFontSize,
          amountFontSize,
          isSmallScreen,
        ),
      ),
    );
  }

  Widget _buildContent(
    double horizontalPadding,
    double verticalPadding,
    double iconSize,
    double titleFontSize,
    double amountFontSize,
    bool isSmallScreen,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colours.whiteColor,
          strokeWidth: 2,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          // Total Earnings Section
          Expanded(
            child: _buildEarningsSection(
              icon: Symbols.trending_up,
              title: 'Total Earnings',
              amount: totalEarnings ?? 25058.00,
              iconSize: iconSize,
              titleFontSize: titleFontSize,
              amountFontSize: amountFontSize,
              isSmallScreen: isSmallScreen,
            ),
          ),
          
          // Divider
          Container(
            height: isSmallScreen ? 40.h : 50.h,
            width: 1,
            color: Colours.whiteColor.withOpacity(0.3),
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.w : 12.w),
          ),
          
          // Total Paid Section
          Expanded(
            child: _buildEarningsSection(
              icon: Symbols.payments,
              title: 'Total Paid',
              amount: totalPaid ?? 10200.00,
              iconSize: iconSize,
              titleFontSize: titleFontSize,
              amountFontSize: amountFontSize,
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection({
    required IconData icon,
    required String title,
    required double amount,
    required double iconSize,
    required double titleFontSize,
    required double amountFontSize,
    required bool isSmallScreen,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon and Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colours.whiteColor.withOpacity(0.9),
              size: iconSize,
            ),
            SizedBox(width: isSmallScreen ? 4.w : 6.w),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: Colours.whiteColor.withOpacity(0.9),
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 4.h : 8.h),
        
        // Amount
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'R${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colours.whiteColor,
              fontSize: amountFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
