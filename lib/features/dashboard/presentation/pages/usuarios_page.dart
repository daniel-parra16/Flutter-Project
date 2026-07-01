import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/features/dashboard/presentation/providers/dashboard_provider.dart';

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _isLoading = true;
  int _rowsPerPage = 10;

  static const _columnKeys = [
    'documento',
    'nombre',
    'apellido',
    'correo',
    'telefono',
    'roles',
    'status',
    'lastLogin',
  ];

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
      final items = await repo.getUsuarios(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        rol: _selectedRole,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar los usuarios.');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    _load();
  }

  List<DataColumn> get _columns {
    return [
      const DataColumn(label: Text('Documento')),
      const DataColumn(label: Text('Nombre')),
      const DataColumn(label: Text('Apellido')),
      const DataColumn(label: Text('Email')),
      const DataColumn(label: Text('Teléfono')),
      const DataColumn(label: Text('Roles')),
      const DataColumn(label: Text('Activo')),
      const DataColumn(label: Text('Último login')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = UserDataSource(_items);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Usuarios',
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
                          labelText: 'Buscar',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedRole,
                      hint: const Text('Rol'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(
                            value: 'ROLE_ADMIN', child: Text('Admin')),
                        DropdownMenuItem(
                            value: 'ROLE_MECANICO', child: Text('Mecánico')),
                        DropdownMenuItem(
                            value: 'ROLE_CLIENTE', child: Text('Cliente')),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedRole = v);
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
                  const Center(child: Text('No se encontraron registros.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1200,
                      child: PaginatedDataTable(
                        header: const Text('Usuarios'),
                        columns: _columns,
                        source: dataSource,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 15, 20],
                        onRowsPerPageChanged: (rows) {
                          if (rows != null) {
                            setState(() => _rowsPerPage = rows);
                          }
                        },
                        columnSpacing: 20,
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

class UserDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _users;

  UserDataSource(this._users);

  @override
  DataRow getRow(int index) {
    final item = _users[index];
    final documento = item['documento'] as Map<String, dynamic>?;
    final roles = item['roles'] as List<dynamic>?;
    final status = item['status'] == true ? 'Sí' : 'No';
    final lastLogin = item['lastLogin']?.toString() ?? '—';

    return DataRow(cells: [
      DataCell(Text(documento?['numero']?.toString() ?? '—')),
      DataCell(Text(item['nombre']?.toString() ?? '—')),
      DataCell(Text(item['apellido']?.toString() ?? '—')),
      DataCell(Text(item['correo']?.toString() ?? '—')),
      DataCell(Text(item['telefono']?.toString() ?? '—')),
      DataCell(Text(roles?.map((role) => role.toString()).join(', ') ?? '—')),
      DataCell(Text(status)),
      DataCell(Text(lastLogin)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;
}
