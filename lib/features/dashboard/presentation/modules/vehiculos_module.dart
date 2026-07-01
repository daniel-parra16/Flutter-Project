import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class VehiculosModule extends ConsumerWidget {
  const VehiculosModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Vehículos',
      fetcher: ({search, rol, estado}) => repo.getVehiculos(search: search),
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Placa')),
        DataColumn(label: Text('Marca')),
        DataColumn(label: Text('Modelo')),
        DataColumn(label: Text('Año')),
        DataColumn(label: Text('Color')),
      ],
      rowsBuilder: (items) => items.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['id']?.toString() ?? '—')),
          DataCell(Text(item['placa']?.toString() ?? '—')),
          DataCell(Text(item['marca']?.toString() ?? '—')),
          DataCell(Text(item['modelo']?.toString() ?? '—')),
          DataCell(Text(item['anio']?.toString() ?? '—')),
          DataCell(Text(item['color']?.toString() ?? '—')),
        ]);
      }).toList(),
    );
  }
}
