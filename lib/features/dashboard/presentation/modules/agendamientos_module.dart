import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class AgendamientosModule extends ConsumerWidget {
  const AgendamientosModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Agendamientos',
      fetcher: ({search, rol, estado}) =>
          repo.getAgendamientos(search: search, estado: estado),
      showState: true,
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Placa')),
        DataColumn(label: Text('Vehículo')),
        DataColumn(label: Text('Fecha / Hora')),
        DataColumn(label: Text('Cliente')),
        DataColumn(label: Text('Estado')),
      ],
      rowsBuilder: (items) => items.map((item) {
        final vehicleLabel = [
          item['vehiculoMarca']?.toString(),
          item['vehiculoModelo']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

        final userName = [
          item['usuarioNombres']?.toString(),
          item['usuarioApellidos']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
        final displayName = userName.isNotEmpty
            ? userName
            : item['usuarioDocumento']?.toString() ?? '—';

        return DataRow(cells: [
          DataCell(Text(item['id']?.toString() ?? '—')),
          DataCell(Text(item['placaVehiculo']?.toString() ?? '—')),
          DataCell(Text(vehicleLabel.isNotEmpty ? vehicleLabel : '—')),
          DataCell(Text(item['fechaHora']?.toString() ?? '—')),
          DataCell(Text(displayName)),
          DataCell(Text(item['estado']?.toString() ?? '—')),
        ]);
      }).toList(),
    );
  }
}
