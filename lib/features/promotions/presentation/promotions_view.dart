import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';

import '../data/promotion_providers.dart';
import '../domain/promotion_models.dart';

class PromotionsView extends ConsumerWidget {
  const PromotionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(promotionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        actions: [
          IconButton(
            tooltip: 'Nueva promoción',
            onPressed: () => _openEditor(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: promotions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('No se pudieron cargar las promociones: $error'),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Aún no hay promociones.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: item.imagenUrl == null
                          ? const Icon(Icons.local_offer_outlined)
                          : Image.network(
                              item.imagenUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                      title: Text(item.titulo),
                      subtitle: Text(
                        item.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Switch(
                        value: item.activo,
                        onChanged: (active) => ref
                            .read(promotionRepositoryProvider)
                            .setActive(item.id, active),
                      ),
                      onTap: () => _openEditor(context, ref, item),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref),
        child: const Icon(Icons.add),
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
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(current == null ? 'Nueva promoción' : 'Editar promoción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: imageUrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen (opcional)',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Publicada'),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
                ListTile(
                  title: Text(
                    'Publicación: ${publishedAt.toLocal().toString().split(' ').first}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: publishedAt,
                    );
                    if (date != null) setState(() => publishedAt = date);
                  },
                ),
                ListTile(
                  title: Text(
                    expiresAt == null
                        ? 'Sin vencimiento'
                        : 'Vence: ${expiresAt!.toLocal().toString().split(' ').first}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: publishedAt,
                      lastDate: DateTime(2100),
                      initialDate: expiresAt ?? publishedAt,
                    );
                    if (date != null) setState(() => expiresAt = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
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
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('$error')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
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
