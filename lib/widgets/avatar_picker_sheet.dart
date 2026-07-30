import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color kGreen = Color(0xFF0C831F);

/// Bottom sheet offering Camera / Gallery avatar selection.
/// Returns the picked [File], or null if cancelled.
class AvatarPickerSheet {
  static Future<File?> show(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: kGreen),
                title: const Text('Take a photo'),
                onTap: () async {
                  final file = await ImagePicker()
                      .pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, file != null ? File(file.path) : null);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: kGreen),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  final file = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, file != null ? File(file.path) : null);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(ctx, null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
