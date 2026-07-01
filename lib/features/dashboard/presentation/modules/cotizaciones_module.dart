import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class CotizacionesModule extends ConsumerWidget {
  const CotizacionesModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Cotizaciones',
      fetcher: ({search, rol, estado}) =>
          repo.getCotizaciones(search: search, estado: estado),
      showState: true,
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Total')),
        DataColumn(label: Text('Fecha entrada')),
        DataColumn(label: Text('Agendamiento')),
        DataColumn(label: Text('Cliente')),
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
          DataCell(Text(item['total']?.toString() ?? '—')),
          DataCell(Text(item['fechaEntrada']?.toString() ?? '—')),
          DataCell(Text(item['agendamientoId']?.toString() ?? '—')),
          DataCell(Text(displayName)),
        ]);
      }).toList(),
    );
  }
}
