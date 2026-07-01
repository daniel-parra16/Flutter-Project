import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class VehiculosPage extends ConsumerStatefulWidget {
  const VehiculosPage({super.key});

  @override
  ConsumerState<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends ConsumerState<VehiculosPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _isLoading = true;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final items = await repo.getVehiculos(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar los vehículos.');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    _load();
  }

  List<DataColumn> get _columns {
    return const [
      DataColumn(label: Text('Placa')),
      DataColumn(label: Text('Marca')),
      DataColumn(label: Text('Modelo')),
      DataColumn(label: Text('Año')),
      DataColumn(label: Text('Color')),
      DataColumn(label: Text('Propietario')),
      DataColumn(label: Text('Teléfono')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = VehicleDataSource(_items);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehículos',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B9EFF),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar (placa, marca, modelo)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(child: Text(_error!))
                else if (_items.isEmpty)
                  const Center(child: Text('No se encontraron vehículos.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1000,
                      child: PaginatedDataTable(
                        header: const Text('Vehículos'),
                        columns: _columns,
                        source: dataSource,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 15, 20],
                        onRowsPerPageChanged: (rows) {
                          if (rows != null) {
                            setState(() => _rowsPerPage = rows);
                          }
                        },
                        columnSpacing: 24,
                        horizontalMargin: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VehicleDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _vehicles;

  VehicleDataSource(this._vehicles);

  @override
  DataRow getRow(int index) {
    final item = _vehicles[index];
    final owner = item['documento'] is Map
        ? '${(item['documento']['numero'] ?? '—')}'
        : '—';

    return DataRow(cells: [
      DataCell(Text(item['placa'] ?? '—')),
      DataCell(Text(item['marca'] ?? '—')),
      DataCell(Text(item['modelo'] ?? '—')),
      DataCell(Text(item['anio']?.toString() ?? '—')),
      DataCell(Text(item['color'] ?? '—')),
      DataCell(Text(owner)),
      DataCell(Text(item['telefono']?.toString() ?? '—')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _vehicles.length;

  @override
  int get selectedRowCount => 0;
}
