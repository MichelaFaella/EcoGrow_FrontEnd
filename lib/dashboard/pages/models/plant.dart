class Plant {
  final String id;
  final String name;
  final String commonName;
  final String? imageUrl;
  final String size;
  final String difficulty;
  final String? imageBase64;

  Plant({
    required this.id,
    required this.name,
    required this.commonName,
    this.imageUrl,
    required this.size,
    required this.difficulty,
    this.imageBase64,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    final plant = (json['plant'] as Map<String, dynamic>?) ?? json;

    final photos = plant['photos'];

    String? imageUrl;
    String? imageBase64;

    if (photos is List && photos.isNotEmpty) {
      final first = photos.first;
      if (first is Map<String, dynamic>) {
        final rawUrl = first['image_url'] ?? first['url'];
        if (rawUrl != null) {
          imageUrl = rawUrl.toString();
        }

        final rawImage = first['image'];
        if (rawImage is String && rawImage.isNotEmpty) {
          imageBase64 = rawImage;
        }
      }
    }

    return Plant(
      id: (plant['id'] ?? json['plant_id'] ?? '').toString(),

      name: plant['scientific_name']?.toString() ??
          plant['common_name']?.toString() ??
          '',

      commonName: plant['common_name']?.toString() ?? '',

      imageUrl: imageUrl,

      size: (json['size'] ?? plant['size'] ?? '').toString(),

      difficulty: plant['difficulty']?.toString() ?? '',

      imageBase64: imageBase64,
    );
  }
}
