import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/promotions/domain/promotion_models.dart';

void main() {
  test('valida una promoción publicada con vencimiento válido', () {
    final draft = PromotionDraft(
      title: '2x1',
      description: 'Dos tacos por el precio de uno.',
      publishedAt: DateTime(2026),
      expiresAt: DateTime(2026, 1, 31),
    );
    expect(draft.validate, returnsNormally);
    expect(draft.toJson()['activo'], true);
  });

  test('rechaza vencimiento anterior a publicación', () {
    final draft = PromotionDraft(
      title: 'Oferta',
      description: 'Descripción',
      publishedAt: DateTime(2026, 2),
      expiresAt: DateTime(2026, 1, 31),
    );
    expect(
      () => draft.validate(),
      throwsA(isA<PromotionValidationException>()),
    );
  });

  test('rechaza contenido vacío', () {
    final draft = PromotionDraft(
      title: '',
      description: 'Descripción',
      publishedAt: DateTime(2026),
    );
    expect(
      () => draft.validate(),
      throwsA(isA<PromotionValidationException>()),
    );
  });
}
