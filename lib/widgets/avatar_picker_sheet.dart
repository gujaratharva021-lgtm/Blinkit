import 'package:flutter/material.dart';
import '../core/avatar/avatar_catalog.dart';

const Color kGreen = Color(0xFF0C831F);

/// Bottom sheet offering a grid of preset avatar "types" to choose from.
/// No camera/gallery upload -- returns the chosen avatar id, or null if
/// the user cancels without picking anything.
class AvatarPickerSheet {
  static Future<String?> show(BuildContext context, {String? currentAvatarId}) async {
    return showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'Choose an avatar',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: kAvatarOptions.map((option) {
                  final selected = option.id == currentAvatarId;
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, option.id),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: kGreen, width: 3)
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: option.color,
                        child: Icon(option.icon, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
