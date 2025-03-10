class Player {
  final int id;
  final String name;
  final String position;
  final String imageUrl;
  final double rating; // Nueva propiedad: puntuación
  final List<int> gamesPlayed; // ✅ Nueva propiedad
  final String? team; // 🔹 Hacer que `team` sea opcional

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.imageUrl,
    required this.rating,
    required this.gamesPlayed, // ✅ Agregado
    this.team, // 🔹 Ahora es opcional
  });

  // Crear objeto a partir de JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      imageUrl: json['image_url'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      gamesPlayed:
          (json['games'] as List?)?.map((g) => g['id'] as int).toList() ??
          [], // ✅ Obtener IDs de partidos
      team:
          json['pivot'] != null
              ? json['pivot']['team'] ?? null
              : null, // 🔹 Extrae `team` solo si existe en `pivot`
    );
  }

  // Convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'image_url': imageUrl,
      'rating': rating,
    };
  }
}
