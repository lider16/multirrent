import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.description,
  });

  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 32, color: AppColors.primary),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onCard,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onCard.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
