import 'package:flutter/material.dart';

/// One selectable preset avatar: an icon on a coloured background.
class AvatarOption {
  final String id;
  final IconData icon;
  final Color color;

  const AvatarOption(this.id, this.icon, this.color);
}

/// The fixed set of avatar "types" a user can pick from.
/// No photo upload -- just pick one of these.
const List<AvatarOption> kAvatarOptions = [
  AvatarOption('avatar_leaf', Icons.eco, Color(0xFF0C831F)),
  AvatarOption('avatar_star', Icons.star, Color(0xFFFFA000)),
  AvatarOption('avatar_pet', Icons.pets, Color(0xFF6D4C41)),
  AvatarOption('avatar_sport', Icons.sports_soccer, Color(0xFF1976D2)),
  AvatarOption('avatar_music', Icons.music_note, Color(0xFF8E24AA)),
  AvatarOption('avatar_food', Icons.local_pizza, Color(0xFFE64A19)),
  AvatarOption('avatar_travel', Icons.flight, Color(0xFF00838F)),
  AvatarOption('avatar_game', Icons.sports_esports, Color(0xFFC2185B)),
  AvatarOption('avatar_smile', Icons.emoji_emotions, Color(0xFFFBC02D)),
  AvatarOption('avatar_robot', Icons.smart_toy, Color(0xFF455A64)),
];

AvatarOption? findAvatarOption(String? id) {
  if (id == null) return null;
  for (final option in kAvatarOptions) {
    if (option.id == id) return option;
  }
  return null;
}

/// Renders the user's chosen preset avatar, or an initial-letter fallback
/// (green circle with the first letter of [fallbackName]) if none is set.
class AvatarDisplay extends StatelessWidget {
  final String? avatarId;
  final String fallbackName;
  final double radius;

  const AvatarDisplay({
    super.key,
    required this.avatarId,
    required this.fallbackName,
    this.radius = 42,
  });

  @override
  Widget build(BuildContext context) {
    final option = findAvatarOption(avatarId);
    if (option != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: option.color,
        child: Icon(option.icon, color: Colors.white, size: radius),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.surfaceContainerHighest,
      child: Text(
        fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0C831F),
        ),
      ),
    );
  }
}
