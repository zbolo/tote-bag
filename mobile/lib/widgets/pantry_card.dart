import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/pantry.dart';

class PantryCard extends StatelessWidget {
  final Pantry pantry;
  final VoidCallback onTap;

  const PantryCard({
    super.key,
    required this.pantry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expiringCount = pantry.expiringItemCount;
    final expiredCount = pantry.expiredItemCount;
    final lowStockCount = pantry.lowStockItemCount;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.kitchen,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pantry.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pantry.totalItems} items',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textTertiaryColor),
                ],
              ),
              if (expiredCount > 0 || expiringCount > 0 || lowStockCount > 0)
                ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (expiredCount > 0)
                        _buildBadge(
                          context,
                          Icons.warning_amber_rounded,
                          '$expiredCount expired',
                          AppTheme.errorColor,
                        ),
                      if (expiringCount > 0)
                        _buildBadge(
                          context,
                          Icons.schedule,
                          '$expiringCount expiring soon',
                          AppTheme.warningColor,
                        ),
                      if (lowStockCount > 0)
                        _buildBadge(
                          context,
                          Icons.trending_down,
                          '$lowStockCount low stock',
                          AppTheme.secondaryColor,
                        ),
                    ],
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
