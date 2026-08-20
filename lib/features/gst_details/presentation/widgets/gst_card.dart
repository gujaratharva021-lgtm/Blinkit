import 'package:flutter/material.dart';
import '../../domain/entities/gst_entity.dart';

class GstCard extends StatelessWidget {
  final GstEntity gst;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GstCard({
    super.key,
    required this.gst,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(gst.gstNumber, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(gst.businessName, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(gst.businessAddress, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            if (isBusy)
              const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

