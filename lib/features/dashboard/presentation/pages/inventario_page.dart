import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class InventarioPage extends ConsumerStatefulWidget {
  const InventarioPage({super.key});

  @override
  ConsumerState<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends ConsumerState<InventarioPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _isLoading = true;

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
      final items = await repo.getInventario(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar los repuestos.');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    _load();
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  List<DataColumn> get _columns {
    return const [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Nombre')),
      DataColumn(label: Text('Marca')),
      DataColumn(label: Text('Categoría')),
      DataColumn(label: Text('Stock')),
      DataColumn(label: Text('Stock mínimo')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = InventoryDataSource(_items);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventario',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B9EFF),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar (nombre, marca, categoría)',
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
                  const Center(child: Text('No se encontraron repuestos.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1000,
                      child: PaginatedDataTable(
                        header: const Text('Inventario'),
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

class InventoryDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _items;

  InventoryDataSource(this._items);

  @override
  DataRow getRow(int index) {
    final item = _items[index];
    return DataRow(cells: [
      DataCell(Text(item['id']?.toString() ?? '—')),
      DataCell(Text(item['nombre']?.toString() ?? '—')),
      DataCell(Text(item['marca']?.toString() ?? '—')),
      DataCell(Text(item['categoria']?.toString() ?? '—')),
      DataCell(Text(item['stock']?.toString() ?? '—')),
      DataCell(Text(item['stockMinimo']?.toString() ?? '—')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _items.length;

  @override
  int get selectedRowCount => 0;
}
