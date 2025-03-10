import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const PlayerAvatar({
    super.key,
    required this.imageUrl,
    this.size = 16,
  }); // Tamaño por defecto más pequeño

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundColor: Colors.grey[300],
      backgroundImage:
          imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/avatar0.png') as ImageProvider,
      child:
          imageUrl.isEmpty
              ? Icon(Icons.person, size: size, color: Colors.grey)
              : null,
    );
  }
}
