import 'package:flutter/material.dart';
import '../../domain/entities/wishlist_item_entity.dart';

class WishlistProductCard extends StatelessWidget {
  final WishlistItemEntity item;
  final bool isBusy;
  final VoidCallback onOpenDetails;
  final VoidCallback onRemove;
  final VoidCallback onMoveToCart;

  const WishlistProductCard({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onOpenDetails,
    required this.onRemove,
    required this.onMoveToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 84,
                        height: 84,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  if (!item.inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Out of\nstock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onRemove,
                          icon: const Icon(Icons.favorite, size: 20, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 2),
                        Text('${item.rating}', style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 4),
                        Text('(${item.ratingCount})', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('?,?${item.price.toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(width: 6),
                        Text(
                          '?,?${item.mrp.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${item.discountPercent}% OFF',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 34,
                      child: isBusy
                          ? const Center(
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: item.inStock ? onMoveToCart : null,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(34),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                item.inStock ? 'Move to Cart' : 'Out of stock',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

