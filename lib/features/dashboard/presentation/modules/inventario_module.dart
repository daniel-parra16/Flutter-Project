import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class InventarioModule extends ConsumerWidget {
  const InventarioModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Inventario',
      fetcher: ({search, rol, estado}) => repo.getInventario(search: search),
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Marca')),
        DataColumn(label: Text('Categoría')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Stock mínimo')),
      ],
      rowsBuilder: (items) => items.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['id']?.toString() ?? '—')),
          DataCell(Text(item['nombre']?.toString() ?? '—')),
          DataCell(Text(item['marca']?.toString() ?? '—')),
          DataCell(Text(item['categoria']?.toString() ?? '—')),
          DataCell(Text(item['stock']?.toString() ?? '—')),
          DataCell(Text(item['stockMinimo']?.toString() ?? '—')),
        ]);
      }).toList(),
    );
  }
}
