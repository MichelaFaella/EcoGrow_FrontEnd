class Plant {
  final String id;
  final String name;
  final String commonName;
  final String? imageUrl;     // eventuale URL da backend (image_url / url)
  final String size;
  final String difficulty;
  final String? imageBase64;  // immagine compressa in base64 (WebP)

  Plant({
    required this.id,
    required this.name,
    required this.commonName,
    this.imageUrl,
    required this.size,
    required this.difficulty,
    this.imageBase64,
  });

  /// [json] è l'oggetto intero di /user_plant/all
  /// struttura tipo:
  /// {
  ///   "location_note": ...,
  ///   "nickname": ...,
  ///   "plant": {
  ///     "id": ...,
  ///     "scientific_name": ...,
  ///     "common_name": ...,
  ///     "difficulty": ...,
  ///     "size": ...,
  ///     "photos": [
  ///       {
  ///         "image_url": "...",
  ///         "url": "...",
  ///         "image": "base64..."
  ///       }
  ///     ]
  ///   }
  /// }
  factory Plant.fromJson(Map<String, dynamic> json) {
    // Estraggo la pianta annidata; se non c'è, uso direttamente json
    final plant = (json['plant'] as Map<String, dynamic>?) ?? json;

    // Foto (può essere null o lista vuota)
    final photos = plant['photos'];

    String? imageUrl;
    String? imageBase64;

    if (photos is List && photos.isNotEmpty) {
      final first = photos.first;
      if (first is Map<String, dynamic>) {
        // URL tradizionale (se esiste ancora)
        final rawUrl = first['image_url'] ?? first['url'];
        if (rawUrl != null) {
          imageUrl = rawUrl.toString();
        }

        // Base64 dell'immagine compressa
        final rawImage = first['image'];
        if (rawImage is String && rawImage.isNotEmpty) {
          imageBase64 = rawImage;
        }
      }
    }

    return Plant(
      // Uso l'id della pianta annidata, oppure eventuale plant_id come fallback
      id: (plant['id'] ?? json['plant_id'] ?? '').toString(),
      // Se scientific_name manca, faccio fallback su common_name
      name: plant['scientific_name']?.toString() ??
          plant['common_name']?.toString() ??
          '',
      commonName: plant['common_name']!.toString(),
      imageUrl: imageUrl,
      size: plant['size']?.toString() ?? '',
      difficulty: plant['difficulty']?.toString() ?? '',
      imageBase64: imageBase64,
    );
  }
}
