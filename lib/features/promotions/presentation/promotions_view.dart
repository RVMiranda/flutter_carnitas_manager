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
    ref.watch(promotionViewModelProvider);
    final t = context.exq;
    final m = t.metrics;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const ExquisssitaPageHeader(title: 'Promociones'),
              Expanded(child: promotions.when(
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
                      padding: EdgeInsets.fromLTRB(
                        m.spaceXl, m.spaceS, m.spaceXl,
                        m.target + m.section + m.spaceXxl,
                      ),
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
                                          Text(item.titulo, style: t.text.titleLarge),
                                          Text(item.descripcion, style: t.body),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: m.target,
                                        minHeight: m.target,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: t.primary,
                                        size: m.iconLarge,
                                      ),
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
                                    await ref
                                        .read(promotionViewModelProvider.notifier)
                                        .setActive(item.id, !item.activo);
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
              )),
            ],
          ),
          Positioned(
            left: m.spaceXl,
            right: m.spaceXl,
            bottom: m.spaceL,
            child: Center(
              child: ExquisssitaAction(
                key: const ValueKey('new-promotion'),
                label: 'Nueva promoción',
                icon: Icons.add_outlined,
                onPressed: () => _openEditor(context, ref),
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
    final saved = await showExquisssitaModal<bool>(
      context: context,
      builder: (_) => _PromotionEditor(current: current, ref: ref),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promoción guardada localmente.')),
      );
    }
  }
}

class _PromotionEditor extends StatefulWidget {
  const _PromotionEditor({required this.current, required this.ref});

  final PromocionesTableData? current;
  final WidgetRef ref;

  @override
  State<_PromotionEditor> createState() => _PromotionEditorState();
}

class _PromotionEditorState extends State<_PromotionEditor> {
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController imageUrl;
  late DateTime publishedAt;
  DateTime? expiresAt;
  late bool active;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final current = widget.current;
    title = TextEditingController(text: current?.titulo ?? '');
    description = TextEditingController(text: current?.descripcion ?? '');
    imageUrl = TextEditingController(text: current?.imagenUrl ?? '');
    publishedAt = current == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(current.fechaPublicacion);
    expiresAt = current?.fechaVencimiento == null
        ? null
        : DateTime.tryParse(current!.fechaVencimiento!);
    active = current?.activo ?? true;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExquisssitaModal(
          title: widget.current == null ? 'Nueva promoción' : 'Editar promoción',
          equalActions: true,
          actions: [
              SizedBox(
                height: context.exq.metrics.target + context.exq.metrics.spaceL,
                child: ExquisssitaAction(
                key: const ValueKey('cancel-promotion'),
                primary: false,
                label: 'Cancelar',
                onPressed: () => Navigator.pop(context, false),
              )),
              SizedBox(
                height: context.exq.metrics.target + context.exq.metrics.spaceL,
                child: ExquisssitaAction(
              key: const ValueKey('save-promotion'),
              label: 'Guardar',
              busy: saving,
              onPressed: () async {
                if (saving) return;
                setState(() => saving = true);
                var saved = false;
                try {
                  final draft = PromotionDraft(
                    id: widget.current?.id,
                    title: title.text,
                    description: description.text,
                    imageUrl: imageUrl.text.trim().isEmpty
                        ? null
                        : imageUrl.text.trim(),
                    publishedAt: publishedAt,
                    expiresAt: expiresAt,
                    active: active,
                  );
                  await widget.ref.read(promotionRepositoryProvider).save(draft);
                  saved = true;
                  if (context.mounted) Navigator.pop(context, true);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Revisa título, descripción y fechas. No fue posible guardar la promoción.',
                      ),
                    ),
                  );
                } finally {
                  if (mounted && !saved) setState(() => saving = false);
                }
              },
              )),
          ],
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: context.exq.metrics.spaceL,
              children: [
                _PromotionField(controller: title, label: 'Título'),
                _PromotionField(
                  controller: description,
                  maxLines: 4,
                  label: 'Descripción',
                ),
                _PromotionField(
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
        );
}

class _PromotionField extends StatelessWidget {
  const _PromotionField({required this.controller, required this.label, this.maxLines = 1});

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: context.exq.metrics.spaceS,
    children: [
      Text(label, style: context.exq.text.titleLarge),
      ExquisssitaFormField(
        controller: controller,
        label: label,
        showLabel: false,
        maxLines: maxLines,
      ),
    ],
  );
}
