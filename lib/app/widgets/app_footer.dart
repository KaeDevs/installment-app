import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppFooter extends StatelessWidget {
  final String version;
  final String licenseLine;
  const AppFooter({super.key, this.version = '1.0.0', this.licenseLine = '© 2025 KaeDevs. MIT License'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.15))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          Text('Version $version', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          Text(licenseLine, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
