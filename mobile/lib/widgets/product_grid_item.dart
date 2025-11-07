import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final bool isInList;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.isInList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isInList ? 1 : 2,
      color: isInList
          ? AppTheme.dividerColor.withValues(alpha: 0.3)
          : AppTheme.surfaceColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Product image or placeholder
              if (product.imageUrl != null)
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 3,
                  child: _buildPlaceholder(),
                ),

              const SizedBox(height: 8),

              // Product name
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isInList
                                ? AppTheme.textSecondaryColor
                                : AppTheme.textPrimaryColor,
                            decoration:
                                isInList ? TextDecoration.lineThrough : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiaryColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite star indicator
              if (product.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.shopping_basket,
          size: 32,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
}
