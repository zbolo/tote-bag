import 'package:cached_network_image/cached_network_image.dart';
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
      color: isInList ? AppTheme.dividerColor : AppTheme.surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product image or placeholder
                Expanded(
                  flex: 3,
                  child: _buildImage(),
                ),

                // Product info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Flexible(
                          child: Text(
                            product.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isInList
                                      ? AppTheme.textSecondaryColor
                                      : AppTheme.textPrimaryColor,
                                  decoration: isInList
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.brand != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            product.brand!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textTertiaryColor,
                                  fontSize: 10,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (product.category != null) ...[
                          const SizedBox(height: 2),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                product.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontSize: 9,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // "In list" overlay
            if (isInList)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.4),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 36,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
              ),

            // Favorite star
            if (product.isFavorite)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({Widget? child}) {
    return Container(
      color: AppTheme.dividerColor,
      child: Center(
        child: child ??
            const Icon(
              Icons.shopping_basket,
              size: 28,
              color: AppTheme.textSecondaryColor,
            ),
      ),
    );
  }
}
