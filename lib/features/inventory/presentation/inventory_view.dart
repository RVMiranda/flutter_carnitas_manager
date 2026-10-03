import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import '../domain/inventory_models.dart';
import 'inventory_view_model.dart';

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});
  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryViewModelProvider);
    final vm = ref.read(inventoryViewModelProvider.notifier);
    final categories = state.products.map((p) => p.categoria).toSet().toList()
      ..sort();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth < 600
                ? 1
                : c.maxWidth < 1000
                ? 2
                : 4;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Menú e inventario',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          ExquisssitaAction(
                            label: 'Nuevo producto',
                            icon: Icons.add,
                            onPressed: () => _editProduct(context, vm),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 280,
                            child: Semantics(
                              label: 'Buscar productos',
                              child: TextField(
                                controller: _search,
                                onChanged: vm.setQuery,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  labelText: 'Buscar producto',
                                ),
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: state.category,
                            hint: const Text('Categoría'),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Todas las categorías'),
                              ),
                              ...categories.map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              ),
                            ],
                            onChanged: (v) =>
                                vm.setCategory(v?.isEmpty == true ? null : v),
                          ),
                          FilterChip(
                            label: const Text('Controlados'),
                            selected: state.controlled == true,
                            onSelected: (v) =>
                                vm.setControlled(v ? true : null),
                          ),
                          FilterChip(
                            label: const Text('No controlados'),
                            selected: state.controlled == false,
                            onSelected: (v) =>
                                vm.setControlled(v ? false : null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: switch (state.status) {
                          InventoryViewStatus.loading => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          InventoryViewStatus.empty => const Center(
                            child: Text('No hay productos con estos filtros.'),
                          ),
                          InventoryViewStatus.error => Center(
                            child: Text(
                              state.error ??
                                  'No fue posible cargar el catálogo.',
                            ),
                          ),
                          _ => GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.35,
                                ),
                            itemCount: state.products.length,
                            itemBuilder: (_, i) => _ProductCard(
                              product: state.products[i],
                              onEdit: () =>
                                  _editProduct(context, vm, state.products[i]),
                              onMovement: state.products[i].controlaInventario
                                  ? () => _movement(
                                      context,
                                      vm,
                                      state.products[i],
                                    )
                                  : null,
                            ),
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editProduct(
    BuildContext context,
    InventoryViewModel vm, [
    ProductosTableData? product,
  ]) async {
    final name = TextEditingController(text: product?.nombre ?? ''),
        price = TextEditingController(
          text: product == null ? '' : '${product.precioCentavos}',
        ),
        category = TextEditingController(text: product?.categoria ?? ''),
        minimum = TextEditingController(
          text: product == null ? '0' : '${product.stockMinimo}',
        ),
        initial = TextEditingController(text: '0');
    var controlled = product?.controlaInventario ?? false;
    final form = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: ProductFormRules.name,
                  ),
                  TextFormField(
                    controller: price,
                    decoration: const InputDecoration(
                      labelText: 'Precio en centavos',
                    ),
                    keyboardType: TextInputType.number,
                    validator: ProductFormRules.price,
                  ),
                  TextFormField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: ProductFormRules.category,
                  ),
                  SwitchListTile(
                    title: const Text('Controla inventario'),
                    value: controlled,
                    onChanged: product == null
                        ? (v) => setState(() => controlled = v)
                        : null,
                  ),
                  if (controlled && product == null)
                    TextFormField(
                      controller: initial,
                      decoration: const InputDecoration(
                        labelText: 'Existencia inicial',
                      ),
                      keyboardType: TextInputType.number,
                      validator: ProductFormRules.stock,
                    ),
                  if (controlled)
                    TextFormField(
                      controller: minimum,
                      decoration: const InputDecoration(
                        labelText: 'Stock mínimo',
                      ),
                      keyboardType: TextInputType.number,
                      validator: ProductFormRules.stock,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                await vm.save(
                  ProductDraft(
                    id: product?.id,
                    name: name.text,
                    priceCents: int.parse(price.text),
                    category: category.text,
                    tracksInventory: controlled,
                    minimumStock: int.parse(minimum.text),
                    initialStock: int.parse(
                      initial.text.isEmpty ? '0' : initial.text,
                    ),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _movement(
    BuildContext context,
    InventoryViewModel vm,
    ProductosTableData product,
  ) async {
    final amount = TextEditingController();
    final form = GlobalKey<FormState>();
    var type = InventoryMovementType.entry;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Movimiento · ${product.nombre}'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                initialValue: type,
                items: InventoryMovementType.values
                    .where(
                      (v) =>
                          v != InventoryMovementType.sale &&
                          v != InventoryMovementType.cancellation,
                    )
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(
                          v == InventoryMovementType.entry
                              ? 'Entrada'
                              : v == InventoryMovementType.waste
                              ? 'Merma'
                              : 'Ajuste',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => type = v!,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: amount,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: ProductFormRules.stock,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              final n = int.parse(amount.text);
              await vm.registerMovement(
                InventoryMovementRequest(
                  productId: product.id,
                  quantity: type == InventoryMovementType.waste ? -n : n,
                  type: type,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    this.onMovement,
  });
  final ProductosTableData product;
  final VoidCallback onEdit;
  final VoidCallback? onMovement;
  @override
  Widget build(BuildContext context) {
    final low =
        product.controlaInventario &&
        product.stockActual <= product.stockMinimo;
    return Semantics(
      label:
          '${product.nombre}, ${product.controlaInventario ? 'producto controlado' : 'sin inventario'}, ${product.precioCentavos} centavos',
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar producto',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              Text(product.categoria),
              const Spacer(),
              Text(
                product.controlaInventario
                    ? 'Stock: ${product.stockActual} · mínimo ${product.stockMinimo}'
                    : 'Inventario no controlado',
                style: TextStyle(
                  color: low ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              if (low)
                const Text(
                  'Stock bajo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onMovement != null)
                    TextButton.icon(
                      onPressed: onMovement,
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Movimiento'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
