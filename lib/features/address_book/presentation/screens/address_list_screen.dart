import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove address'),
        content: const Text('This address will be removed from your address book.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AddressProvider>().deleteAddress(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Address Book')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add address'),
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AddressProvider provider) {
    switch (provider.status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return SkeletonListView(
          itemBuilder: (_) => const _AddressCardSkeleton(),
        );
      case ViewStatus.error:
        return ErrorStateWidget(
          message: provider.errorMessage ?? 'Please try again.',
          onRetry: provider.loadAddresses,
        );
      case ViewStatus.empty:
        return EmptyStateWidget(
          icon: Icons.location_off_outlined,
          title: 'No saved addresses',
          message: 'Add an address to make checkout faster next time.',
          actionLabel: 'Add address',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
          ),
        );
      case ViewStatus.loaded:
        return RefreshIndicator(
          onRefresh: provider.loadAddresses,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = provider.addresses[index];
              return AddressCard(
                address: address,
                isBusy: provider.pendingIds.contains(address.id),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditAddressScreen(existing: address),
                  ),
                ),
                onDelete: () => _confirmDelete(context, address.id),
                onSetDefault: () => provider.setDefaultAddress(address.id),
              );
            },
          ),
        );
    }
  }
}

class _AddressCardSkeleton extends StatelessWidget {
  const _AddressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 16, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 10),
            SkeletonBox(width: 100, height: 12, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 12, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 6),
            SkeletonBox(width: 200, height: 12, borderRadius: BorderRadius.circular(4)),
          ],
        ),
      ),
    );
  }
}

