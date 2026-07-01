import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class OrdenesModule extends ConsumerWidget {
  const OrdenesModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Órdenes',
      fetcher: ({search, rol, estado}) =>
          repo.getOrdenes(search: search, estado: estado),
      showState: true,
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Vehículo')),
        DataColumn(label: Text('Cliente')),
        DataColumn(label: Text('Fecha entrada')),
      ],
      rowsBuilder: (items) => items.map((item) {
        final userName = [
          item['usuarioNombres']?.toString(),
          item['usuarioApellidos']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
        final displayName = userName.isNotEmpty
            ? userName
            : item['usuarioDocumento']?.toString() ?? '—';

        return DataRow(cells: [
          DataCell(Text(item['id']?.toString() ?? '—')),
          DataCell(Text(item['estado']?.toString() ?? '—')),
          DataCell(Text(item['vehiculoPlaca']?.toString() ?? '—')),
          DataCell(Text(displayName)),
          DataCell(Text(item['fechaEntrada']?.toString() ?? '—')),
        ]);
      }).toList(),
    );
  }
}
