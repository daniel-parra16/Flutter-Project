import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class OrdenesPage extends ConsumerStatefulWidget {
  const OrdenesPage({super.key});

  @override
  ConsumerState<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends ConsumerState<OrdenesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedState;
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
      final items = await repo.getOrdenes(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        estado: _selectedState,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar las órdenes.');
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
      DataColumn(label: Text('Estado')),
      DataColumn(label: Text('Vehículo')),
      DataColumn(label: Text('Cliente')),
      DataColumn(label: Text('Fecha entrada')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = OrderDataSource(_items);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Órdenes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B9EFF),
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar (id, vehículo)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedState,
                      hint: const Text('Estado'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(
                            value: 'RECIBIDO', child: Text('Recibido')),
                        DropdownMenuItem(
                            value: 'EN_DIAGNOSTICO',
                            child: Text('En diagnóstico')),
                        DropdownMenuItem(
                            value: 'ESPERANDO_REPUESTOS',
                            child: Text('Esperando repuestos')),
                        DropdownMenuItem(
                            value: 'EN_REPARACION',
                            child: Text('En reparación')),
                        DropdownMenuItem(value: 'LISTA', child: Text('Lista')),
                        DropdownMenuItem(
                            value: 'ENTREGADA', child: Text('Entregada')),
                        DropdownMenuItem(
                            value: 'CANCELADA', child: Text('Cancelada')),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedState = v);
                        _onSearch();
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                        onPressed: _onSearch, child: const Text('Buscar'))
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(child: Text(_error!))
                else if (_items.isEmpty)
                  const Center(child: Text('No se encontraron órdenes.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1100,
                      child: PaginatedDataTable(
                        header: const Text('Órdenes'),
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

class OrderDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _items;

  OrderDataSource(this._items);

  @override
  DataRow getRow(int index) {
    final item = _items[index];
    final userName = [
      item['usuarioNombres']?.toString(),
      item['usuarioApellidos']?.toString(),
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
    final displayName = userName.isNotEmpty
        ? userName
        : item['usuarioDocumento']?.toString() ?? '—';

    return DataRow(cells: [
      DataCell(Text(item['id']?.toString() ?? '—')),
      DataCell(Text(item['estado'] ?? '—')),
      DataCell(Text(item['vehiculoPlaca']?.toString() ?? '—')),
      DataCell(Text(displayName)),
      DataCell(Text(item['fechaEntrada']?.toString() ?? '—')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _items.length;

  @override
  int get selectedRowCount => 0;
}
