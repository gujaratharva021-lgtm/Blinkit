import 'package:flutter/material.dart';
import '../../widgets/confirm_dialog.dart';
import 'app_permissions_screen.dart';

const Color kGreen = Color(0xFF0C831F);

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Account privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.shield_outlined, color: kGreen),
              title: const Text('App permissions'),
              subtitle: const Text('Location, camera, notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AppPermissionsScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete account',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('This action is permanent'),
              onTap: () async {
                final ok = await ConfirmDialog.show(
                  context,
                  title: 'Delete account',
                  message:
                      'This will permanently delete your account and all associated data. This cannot be undone.',
                  confirmLabel: 'Delete',
                  confirmColor: Colors.red,
                );
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Deletion request submitted'),
                        backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}