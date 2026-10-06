import 'package:uuid/uuid.dart';

class Promotion {
  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.active,
    this.imageUrl,
    this.expiresAt,
  });
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final bool active;

  bool get isCurrentlyPublished {
    final now = DateTime.now();
    return active &&
        !publishedAt.isAfter(now) &&
        (expiresAt == null || expiresAt!.isAfter(now));
  }
}

class PromotionDraft {
  PromotionDraft({
    required this.title,
    required this.description,
    required this.publishedAt,
    this.imageUrl,
    this.expiresAt,
    this.active = true,
    String? id,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final bool active;

  void validate() {
    if (title.trim().isEmpty || title.trim().length > 120) {
      throw const PromotionValidationException(
        'El título debe tener entre 1 y 120 caracteres.',
      );
    }
    if (description.trim().isEmpty || description.trim().length > 2000) {
      throw const PromotionValidationException('La descripción no es válida.');
    }
    if (expiresAt != null && expiresAt!.isBefore(publishedAt)) {
      throw const PromotionValidationException(
        'La fecha de vencimiento debe ser posterior a la publicación.',
      );
    }
    if (imageUrl != null && imageUrl!.length > 2048) {
      throw const PromotionValidationException(
        'La URL de imagen es demasiado larga.',
      );
    }
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'titulo': title.trim(),
    'descripcion': description.trim(),
    'imagen_url': imageUrl,
    'fecha_publicacion': publishedAt.toUtc().toIso8601String(),
    'fecha_vencimiento': expiresAt?.toIso8601String().split('T').first,
    'activo': active,
  };
}

class PromotionValidationException implements Exception {
  const PromotionValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}
