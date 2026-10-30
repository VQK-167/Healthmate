import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 44,
    this.showCamera = false,
    this.onTap,
  });

  final AppUser? user;
  final double radius;
  final bool showCamera;
  final VoidCallback? onTap;

  static const _colors = [
    Color(0xFF00695C),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFF00838F),
    Color(0xFFAD1457),
  ];

  static const _icons = [
    Icons.person,
    Icons.face,
    Icons.sentiment_satisfied_alt,
    Icons.emoji_emotions,
    Icons.pets,
    Icons.sports_soccer,
    Icons.local_florist,
    Icons.star,
  ];

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider();
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColor(),
      foregroundImage: image,
      child: image == null
          ? Icon(_fallbackIcon(), size: radius, color: Colors.white)
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          fallback,
          if (showCamera)
            Positioned(
              right: -2,
              bottom: -2,
              child: CircleAvatar(
                radius: radius * .27,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.camera_alt, size: radius * .28, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _imageProvider() {
    final encoded = user?.avatarBase64;
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final bytes = base64Decode(encoded);
        return MemoryImage(Uint8List.fromList(bytes));
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  Color _backgroundColor() {
    final index = user?.avatarIndex;
    return index == null ? Colors.blueGrey : _colors[index % _colors.length];
  }

  IconData _fallbackIcon() {
    final index = user?.avatarIndex;
    return index == null ? Icons.person : _icons[index % _icons.length];
  }
}
