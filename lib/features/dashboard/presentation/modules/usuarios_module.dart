import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/module_base.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class UsuariosModule extends ConsumerWidget {
  const UsuariosModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(dashboardRepositoryProvider);
    return ModuleBase(
      title: 'Usuarios',
      fetcher: ({search, rol, estado}) =>
          repo.getUsuarios(search: search, rol: rol),
      showRole: true,
      columnsBuilder: () => const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Apellido')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Teléfono')),
        DataColumn(label: Text('Activo')),
      ],
      rowsBuilder: (items) => items.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['id']?.toString() ?? '—')),
          DataCell(Text(item['nombre']?.toString() ?? '—')),
          DataCell(Text(item['apellido']?.toString() ?? '—')),
          DataCell(Text(item['email']?.toString() ?? '—')),
          DataCell(Text(item['telefono']?.toString() ?? '—')),
          DataCell(Text(item['activo'] == true ? 'Sí' : 'No')),
        ]);
      }).toList(),
    );
  }
}
