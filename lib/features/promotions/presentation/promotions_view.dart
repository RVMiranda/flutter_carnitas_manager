import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';

import '../../../app/theme/exquisssita_tokens.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../data/promotion_providers.dart';
import '../domain/promotion_models.dart';
import 'promotion_view_model.dart';

class PromotionsView extends ConsumerWidget {
  const PromotionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(promotionsProvider);
    final actionVm = ref.read(promotionViewModelProvider.notifier);
    final t = context.exq;
    final m = t.metrics;
    return Scaffold(
      body: Column(
        children: [
          ExquisssitaPageHeader(
            title: 'Promociones',
            action: ExquisssitaAction(
              label: 'Nueva promoción',
              icon: Icons.add_outlined,
              onPressed: () => _openEditor(context, ref),
            ),
          ),
          Expanded(
            child: promotions.when(
              loading: () => const ExquisssitaSkeleton(),
              error: (_, _) => ExquisssitaErrorState(
                onRetry: () => ref.invalidate(promotionsProvider),
              ),
              data: (items) => items.isEmpty
                  ? const SingleChildScrollView(
                      child: ExquisssitaEmptyState(
                        message: 'Aún no hay promociones.',
                        icon: Icons.local_offer_outlined,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(m.spaceXl),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(height: m.spaceM),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ExquisssitaSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ExquisssitaPressable(
                                label:
                                    'Editar ${item.titulo}. ${item.descripcion}',
                                onPressed: () =>
                                    _openEditor(context, ref, item),
                                child: Row(
                                  children: [
                                    ExcludeSemantics(
                                      child: item.imagenUrl == null
                                          ? Icon(
                                              Icons.local_offer_outlined,
                                              size: m.iconLarge,
                                              color: t.foreground,
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    m.radiusSmall,
                                                  ),
                                              child: Image.network(
                                                item.imagenUrl!,
                                                width: m.image,
                                                height: m.image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => Icon(
                                                  Icons.broken_image_outlined,
                                                  color: t.foreground,
                                                  size: m.iconLarge,
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: m.spaceM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.titulo, style: t.label),
                                          Text(item.descripcion, style: t.body),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit_outlined,
                                      color: t.foreground,
                                      size: m.iconSmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: m.spaceS),
                              ExquisssitaAction(
                                primary: false,
                                label: item.activo
                                    ? 'Desactivar promoción'
                                    : 'Publicar promoción',
                                icon: item.activo
                                    ? Icons.check_circle_outline
                                    : Icons.radio_button_unchecked_outlined,
                                onPressed: () async {
                                  try {
                                    await actionVm.setActive(item.id, !item.activo);
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No fue posible cambiar la publicación. Intenta de nuevo.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    PromocionesTableData? current,
  ]) async {
    final title = TextEditingController(text: current?.titulo ?? '');
    final description = TextEditingController(text: current?.descripcion ?? '');
    final imageUrl = TextEditingController(text: current?.imagenUrl ?? '');
    var publishedAt = current == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(current.fechaPublicacion);
    DateTime? expiresAt = current?.fechaVencimiento == null
        ? null
        : DateTime.tryParse(current!.fechaVencimiento!);
    var active = current?.activo ?? true;
    var saving = false;
    final saved = await showExquisssitaModal<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => ExquisssitaModal(
          title: current == null ? 'Nueva promoción' : 'Editar promoción',
          actions: [
            ExquisssitaAction(
              primary: false,
              label: 'Cancelar',
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            ExquisssitaAction(
              label: 'Guardar',
              busy: saving,
              onPressed: () async {
                if (saving) return;
                setState(() => saving = true);
                try {
                  final draft = PromotionDraft(
                    id: current?.id,
                    title: title.text,
                    description: description.text,
                    imageUrl: imageUrl.text.trim().isEmpty
                        ? null
                        : imageUrl.text.trim(),
                    publishedAt: publishedAt,
                    expiresAt: expiresAt,
                    active: active,
                  );
                  await ref.read(promotionRepositoryProvider).save(draft);
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (_) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Revisa título, descripción y fechas. No fue posible guardar la promoción.',
                      ),
                    ),
                  );
                } finally {
                  if (dialogContext.mounted) setState(() => saving = false);
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExquisssitaFormField(controller: title, label: 'Título'),
                ExquisssitaFormField(
                  controller: description,
                  maxLines: 4,
                  label: 'Descripción',
                ),
                ExquisssitaFormField(
                  controller: imageUrl,
                  label: 'URL de imagen (opcional)',
                ),
                ExquisssitaAction(
                  primary: false,
                  label: active ? 'Publicada: sí' : 'Publicada: no',
                  onPressed: () => setState(() => active = !active),
                ),
                ExquisssitaAction(
                  primary: false,
                  label:
                      'Publicación: ${publishedAt.toLocal().toString().split(' ').first}',
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: publishedAt,
                    );
                    if (date != null && context.mounted) {
                      setState(() => publishedAt = date);
                    }
                  },
                ),
                ExquisssitaAction(
                  primary: false,
                  label: expiresAt == null
                      ? 'Sin vencimiento'
                      : 'Vence: ${expiresAt!.toLocal().toString().split(' ').first}',
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: publishedAt,
                      lastDate: DateTime(2100),
                      initialDate:
                          expiresAt == null || expiresAt!.isBefore(publishedAt)
                          ? publishedAt
                          : expiresAt,
                    );
                    if (date != null && context.mounted) {
                      setState(() => expiresAt = date);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    title.dispose();
    description.dispose();
    imageUrl.dispose();
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promoción guardada localmente.')),
      );
    }
  }
}
