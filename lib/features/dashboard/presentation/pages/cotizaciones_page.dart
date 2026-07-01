import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class CotizacionesPage extends ConsumerStatefulWidget {
  const CotizacionesPage({super.key});

  @override
  ConsumerState<CotizacionesPage> createState() => _CotizacionesPageState();
}

class _CotizacionesPageState extends ConsumerState<CotizacionesPage> {
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
      final items = await repo.getCotizaciones(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        estado: _selectedState,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar las cotizaciones.');
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
      DataColumn(label: Text('Total')),
      DataColumn(label: Text('Fecha entrada')),
      DataColumn(label: Text('Agendamiento')),
      DataColumn(label: Text('Cliente')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = QuoteDataSource(_items);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cotizaciones',
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
                          labelText: 'Buscar (id, cliente)',
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
                            value: 'PENDIENTE', child: Text('Pendiente')),
                        DropdownMenuItem(
                            value: 'APROBADA', child: Text('Aprobada')),
                        DropdownMenuItem(
                            value: 'RECHAZADA', child: Text('Rechazada')),
                        DropdownMenuItem(
                            value: 'VENCIDA', child: Text('Vencida')),
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
                  const Center(child: Text('No se encontraron cotizaciones.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1000,
                      child: PaginatedDataTable(
                        header: const Text('Cotizaciones'),
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

class QuoteDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _items;

  QuoteDataSource(this._items);

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
      DataCell(Text(item['total']?.toString() ?? '—')),
      DataCell(Text(item['fechaEntrada']?.toString() ?? '—')),
      DataCell(Text(item['agendamientoId']?.toString() ?? '—')),
      DataCell(Text(displayName)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _items.length;

  @override
  int get selectedRowCount => 0;
}
