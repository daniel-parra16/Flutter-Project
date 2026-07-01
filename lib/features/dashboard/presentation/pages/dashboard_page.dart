import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inno/core/network/providers.dart';
import 'package:flutter_inno/features/dashboard/dashboard.dart';
import 'package:flutter_inno/core/utils/jwt_decoder.dart';
import 'package:flutter_inno/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/inicio_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/usuarios_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/vehiculos_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/agendamientos_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/cotizaciones_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/ordenes_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/inventario_module.dart';

const _kBg = Color(0xFF0F1923);
const _kCard = Color(0xFF152030);
const _kBorder = Color(0xFF1E3048);
const _kAccent = Color(0xFF3B9EFF);
const _kTextPrimary = Color(0xFFF0F6FF);
const _kTextSecondary = Color(0xFF5A7A9A);
const _kSuccess = Color(0xFF2ECC71);
const _kWarning = Color(0xFFFFB84D);

const _sectionTitles = {
  _DashboardSection.inicio: 'Dashboard',
  _DashboardSection.usuarios: 'Usuarios',
  _DashboardSection.vehiculos: 'Vehículos',
  _DashboardSection.agendamientos: 'Agendamientos',
  _DashboardSection.cotizaciones: 'Cotizaciones',
  _DashboardSection.ordenes: 'Órdenes',
  _DashboardSection.inventario: 'Inventario',
};

const _sectionSubtitles = {
  _DashboardSection.inicio: 'Resumen de cliente y estado actual.',
  _DashboardSection.usuarios: 'Filtra y consulta usuarios activos.',
  _DashboardSection.vehiculos: 'Busca vehículos por placa, marca o modelo.',
  _DashboardSection.agendamientos: 'Consulta citas y estados de servicio.',
  _DashboardSection.cotizaciones: 'Revisa cotizaciones pendientes y aprobadas.',
  _DashboardSection.ordenes: 'Controla órdenes de servicio y estados.',
  _DashboardSection.inventario: 'Visualiza movimientos de inventario.',
};

const _sectionIcons = {
  _DashboardSection.inicio: Icons.dashboard_rounded,
  _DashboardSection.usuarios: Icons.people_rounded,
  _DashboardSection.vehiculos: Icons.directions_car_rounded,
  _DashboardSection.agendamientos: Icons.event_note_rounded,
  _DashboardSection.cotizaciones: Icons.request_quote_rounded,
  _DashboardSection.ordenes: Icons.build_circle_rounded,
  _DashboardSection.inventario: Icons.inventory_2_rounded,
};

enum _DashboardSection {
  inicio,
  usuarios,
  vehiculos,
  agendamientos,
  cotizaciones,
  ordenes,
  inventario,
}

const _roles = [
  {'label': 'Admin', 'value': 'ROLE_ADMIN'},
  {'label': 'Mecánico', 'value': 'ROLE_MECANICO'},
  {'label': 'Cliente', 'value': 'ROLE_CLIENTE'},
];

const _agendamientoStates = [
  {'label': 'Pendiente', 'value': 'PENDIENTE'},
  {'label': 'Confirmado', 'value': 'CONFIRMADO'},
  {'label': 'Se presenta', 'value': 'SE_PRESENTA'},
  {'label': 'No se presenta', 'value': 'NO_SE_PRESENTA'},
  {'label': 'Cancelado', 'value': 'CANCELADO'},
];

const _cotizacionStates = [
  {'label': 'Pendiente', 'value': 'PENDIENTE'},
  {'label': 'Aprobada', 'value': 'APROBADA'},
  {'label': 'Rechazada', 'value': 'RECHAZADA'},
  {'label': 'Vencida', 'value': 'VENCIDA'},
];

const _ordenStates = [
  {'label': 'Recibido', 'value': 'RECIBIDO'},
  {'label': 'En Diagnóstico', 'value': 'EN_DIAGNOSTICO'},
  {'label': 'Esperando Repuestos', 'value': 'ESPERANDO_REPUESTOS'},
  {'label': 'En Reparación', 'value': 'EN_REPARACION'},
  {'label': 'Lista', 'value': 'LISTA'},
  {'label': 'Entregada', 'value': 'ENTREGADA'},
  {'label': 'Cancelada', 'value': 'CANCELADA'},
];

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;
  _DashboardSection _selectedSection = _DashboardSection.inicio;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedState;
  Timer? _debounce;
  final GlobalKey _avatarKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.getAccessToken();
      if (token == null) {
        if (!mounted) return;
        context.replace('/login');
        return;
      }

      final documento = await storage.getDocumento() ?? '';
      if (documento.isEmpty) {
        if (!mounted) return;
        context.replace('/login');
        return;
      }

      final repo = ref.read(dashboardRepositoryProvider);
      if (_selectedSection == _DashboardSection.inicio) {
        final data = await repo.getClienteDashboard(documento);
        if (!mounted) return;
        setState(() {
          _dashboardData = data;
          _items = [];
          _isLoading = false;
        });
        return;
      }

      final search = _searchController.text.trim();
      final items = await _loadSectionItems(repo, search);
      if (!mounted) return;
      setState(() {
        _items = items;
        _dashboardData = null;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await ref.read(secureStorageProvider).deleteTokens();
        if (!mounted) return;
        context.replace('/login');
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar los datos. Intenta de nuevo.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Error inesperado. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadSectionItems(
    DashboardRepository repo,
    String search,
  ) async {
    switch (_selectedSection) {
      case _DashboardSection.usuarios:
        return repo.getUsuarios(
            search: search.isEmpty ? null : search, rol: _selectedRole);
      case _DashboardSection.vehiculos:
        return repo.getVehiculos(search: search.isEmpty ? null : search);
      case _DashboardSection.agendamientos:
        return repo.getAgendamientos(
            search: search.isEmpty ? null : search, estado: _selectedState);
      case _DashboardSection.cotizaciones:
        return repo.getCotizaciones(
            search: search.isEmpty ? null : search, estado: _selectedState);
      case _DashboardSection.ordenes:
        return repo.getOrdenes(
            search: search.isEmpty ? null : search, estado: _selectedState);
      case _DashboardSection.inventario:
        return repo.getInventario(search: search.isEmpty ? null : search);
      case _DashboardSection.inicio:
        return [];
    }
    return [];
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _load();
  }

  void _selectSection(_DashboardSection section) {
    Navigator.of(context).maybePop();
    if (_selectedSection == section) {
      _load();
      return;
    }

    setState(() {
      _selectedSection = section;
      _searchController.clear();
      _selectedRole = null;
      _selectedState = null;
      _items = [];
      _dashboardData = null;
      _error = null;
    });
    _load();
  }

  int get _vehiculos => (_dashboardData?['vehiculos'] as num?)?.toInt() ?? 0;
  int get _activas => (_dashboardData?['ordenesActivas'] as num?)?.toInt() ?? 0;
  int get _finalizadas =>
      (_dashboardData?['ordenesFinalizadas'] as num?)?.toInt() ?? 0;
  int get _cotizaciones =>
      (_dashboardData?['cotizacionesPendientes'] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kTextPrimary),
        title: Text(
          _sectionTitles[_selectedSection]!,
          style: const TextStyle(
              color: _kTextPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              // show a small contextual menu near the avatar with Config and Logout
              final renderBox = context.findRenderObject() as RenderBox?;
              final overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final position =
                  renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
              final left = position.dx;
              final top = position.dy + (renderBox?.size.height ?? 40);
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  left,
                  top,
                  overlay.size.width - left - (renderBox?.size.width ?? 40),
                  0,
                ),
                items: [
                  PopupMenuItem(
                    value: 'config',
                    child: Row(children: const [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Configuración')
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(children: const [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Salir')
                    ]),
                  ),
                ],
              );
              if (selected == 'logout') {
                await _handleLogout();
              } else if (selected == 'config') {
                // placeholder: open settings - no route implemented yet
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _kBorder,
                child: FutureBuilder<String?>(
                  future: _getInitials(),
                  builder: (context, snap) {
                    final text = (snap.data ?? '?');
                    return Text(text,
                        style: const TextStyle(
                            color: _kTextPrimary, fontWeight: FontWeight.w700));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      endDrawer: _buildEndDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : _error != null
              ? _buildError()
              : _selectedSection == _DashboardSection.inicio
                  ? _buildDashboardContent()
                  : _buildModuleContent(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _kBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('InnoGarage',
                      style: TextStyle(
                          color: _kAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('Navega entre los módulos del taller.',
                      style: TextStyle(color: _kTextSecondary, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: _DashboardSection.values
                    .map((section) => _buildDrawerItem(section))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(_DashboardSection section) {
    final active = section == _selectedSection;
    return ListTile(
      leading: Icon(_sectionIcons[section],
          color: active ? _kAccent : _kTextSecondary),
      title: Text(
        _sectionTitles[section]!,
        style: TextStyle(
          color: active ? _kAccent : _kTextPrimary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      tileColor: active ? const Color(0xFF132039) : Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      onTap: () {
        // navigate to module route
        final route = _routeForSection(section);
        if (route != null) {
          Navigator.of(context).pop();
          // use go_router to push
          context.push(route);
        } else {
          _selectSection(section);
        }
      },
    );
  }

  String? _routeForSection(_DashboardSection section) {
    switch (section) {
      case _DashboardSection.inicio:
        return '/dashboard';
      case _DashboardSection.usuarios:
        return '/usuarios';
      case _DashboardSection.vehiculos:
        return '/vehiculos';
      case _DashboardSection.agendamientos:
        return '/agendamientos';
      case _DashboardSection.cotizaciones:
        return '/cotizaciones';
      case _DashboardSection.ordenes:
        return '/ordenes';
      case _DashboardSection.inventario:
        return '/inventario';
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: _kTextSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Ocurrió un problema.',
              style: const TextStyle(color: _kTextPrimary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: RefreshIndicator(
        color: _kAccent,
        backgroundColor: _kCard,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(),
                  const SizedBox(height: 24),
                  _buildWelcome(),
                  const SizedBox(height: 24),
                  _buildStats(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Resumen del cliente'),
                  const SizedBox(height: 12),
                  _buildOrderSummary(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleContent() {
    Widget content;
    switch (_selectedSection) {
      case _DashboardSection.inicio:
        content = const InicioModule();
        break;
      case _DashboardSection.usuarios:
        content = const UsuariosModule();
        break;
      case _DashboardSection.vehiculos:
        content = const VehiculosModule();
        break;
      case _DashboardSection.agendamientos:
        content = const AgendamientosModule();
        break;
      case _DashboardSection.cotizaciones:
        content = const CotizacionesModule();
        break;
      case _DashboardSection.ordenes:
        content = const OrdenesModule();
        break;
      case _DashboardSection.inventario:
        content = const InventarioModule();
        break;
    }

    return SafeArea(
      child: RefreshIndicator(
        color: _kAccent,
        backgroundColor: _kCard,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(),
                  const SizedBox(height: 20),
                  // Wrap module content inside card-like surface
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _kCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _kBorder),
                    ),
                    child: content,
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sectionTitles[_selectedSection]!,
          style: const TextStyle(
              color: _kAccent, fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _sectionSubtitles[_selectedSection]!,
          style: const TextStyle(
              color: _kTextSecondary, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _kTextPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Bienvenido,',
            style: TextStyle(color: _kTextSecondary, fontSize: 13)),
        SizedBox(height: 2),
        Text(
          'Panel de cliente',
          style: TextStyle(
              color: _kTextPrimary, fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final showRole = _selectedSection == _DashboardSection.usuarios;
    final showState = _selectedSection == _DashboardSection.agendamientos ||
        _selectedSection == _DashboardSection.cotizaciones ||
        _selectedSection == _DashboardSection.ordenes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Wrap(
        runSpacing: 16,
        spacing: 16,
        alignment: WrapAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _load(),
              style: const TextStyle(color: _kTextPrimary),
              decoration: InputDecoration(
                labelText: 'Buscar',
                labelStyle: const TextStyle(color: _kTextSecondary),
                hintText: 'Escribe placa, nombre, documento, correo...',
                hintStyle: const TextStyle(color: _kTextSecondary),
                prefixIcon: const Icon(Icons.search, color: _kTextSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: _kTextSecondary),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: _kBg.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: _kBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: _kAccent),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (showRole)
            _buildDropdown('Rol', _selectedRole, _roles, (value) {
              setState(() {
                _selectedRole = value;
              });
              _load();
            }),
          if (showState)
            _buildDropdown(
                'Estado',
                _selectedState,
                _selectedSection == _DashboardSection.agendamientos
                    ? _agendamientoStates
                    : _selectedSection == _DashboardSection.cotizaciones
                        ? _cotizacionStates
                        : _ordenStates, (value) {
              setState(() {
                _selectedState = value;
              });
              _load();
            }),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        style: const TextStyle(color: _kTextPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _kTextSecondary),
          filled: true,
          fillColor: _kBg.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _kBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _kAccent),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: [
          const DropdownMenuItem(
              value: null,
              child: Text('Todos', style: TextStyle(color: _kTextPrimary))),
          ...options.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label']!,
                  style: const TextStyle(color: _kTextPrimary)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados (${_items.length})',
            style: const TextStyle(
                color: _kTextPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No se encontraron registros para esta búsqueda.',
                  style: TextStyle(color: _kTextSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => const Color(0xFF1E3048)),
                dataRowColor: WidgetStateProperty.resolveWith(
                    (states) => _kBg.withValues(alpha: 0.02)),
                columns: _tableColumns(),
                rows: _tableRows(),
                headingTextStyle: const TextStyle(
                    color: _kTextPrimary, fontWeight: FontWeight.w600),
                dataTextStyle: const TextStyle(color: _kTextPrimary),
              ),
            ),
        ],
      ),
    );
  }

  List<DataColumn> _tableColumns() {
    switch (_selectedSection) {
      case _DashboardSection.usuarios:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Apellido')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Teléfono')),
          DataColumn(label: Text('Activo')),
        ];
      case _DashboardSection.vehiculos:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Placa')),
          DataColumn(label: Text('Marca')),
          DataColumn(label: Text('Modelo')),
          DataColumn(label: Text('Año')),
          DataColumn(label: Text('Color')),
        ];
      case _DashboardSection.agendamientos:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Placa')),
          DataColumn(label: Text('Vehículo')),
          DataColumn(label: Text('Fecha / Hora')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Estado')),
        ];
      case _DashboardSection.cotizaciones:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Fecha entrada')),
          DataColumn(label: Text('Agendamiento')),
          DataColumn(label: Text('Cliente')),
        ];
      case _DashboardSection.ordenes:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Vehículo')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Fecha entrada')),
        ];
      case _DashboardSection.inventario:
        return const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Marca')),
          DataColumn(label: Text('Categoría')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Stock mínimo')),
        ];
      case _DashboardSection.inicio:
        return const [];
    }
  }

  List<DataRow> _tableRows() {
    return _items.map((item) {
      return DataRow(
        cells: _tableRowCells(item),
      );
    }).toList();
  }

  List<DataCell> _tableRowCells(Map<String, dynamic> item) {
    DataCell cell(String value) =>
        DataCell(Text(value, style: const TextStyle(color: _kTextPrimary)));

    switch (_selectedSection) {
      case _DashboardSection.usuarios:
        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['nombre']?.toString() ?? '—'),
          cell(item['apellido']?.toString() ?? '—'),
          cell(item['email']?.toString() ?? '—'),
          cell(item['telefono']?.toString() ?? '—'),
          cell(item['activo'] == true ? 'Sí' : 'No'),
        ];
      case _DashboardSection.vehiculos:
        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['placa']?.toString() ?? '—'),
          cell(item['marca']?.toString() ?? '—'),
          cell(item['modelo']?.toString() ?? '—'),
          cell(item['anio']?.toString() ?? '—'),
          cell(item['color']?.toString() ?? '—'),
        ];
      case _DashboardSection.agendamientos:
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

        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['placaVehiculo']?.toString() ?? '—'),
          cell(vehicleLabel.isNotEmpty ? vehicleLabel : '—'),
          cell(_formatDate(item['fechaHora']?.toString())),
          cell(displayName),
          cell(item['estado']?.toString() ?? '—'),
        ];
      case _DashboardSection.cotizaciones:
        final userName = [
          item['usuarioNombres']?.toString(),
          item['usuarioApellidos']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
        final displayName = userName.isNotEmpty
            ? userName
            : item['usuarioDocumento']?.toString() ?? '—';

        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['estado']?.toString() ?? '—'),
          cell(item['total']?.toString() ?? '—'),
          cell(_formatDate(item['fechaEntrada']?.toString())),
          cell(item['agendamientoId']?.toString() ?? '—'),
          cell(displayName),
        ];
      case _DashboardSection.ordenes:
        final userName = [
          item['usuarioNombres']?.toString(),
          item['usuarioApellidos']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
        final displayName = userName.isNotEmpty
            ? userName
            : item['usuarioDocumento']?.toString() ?? '—';

        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['estado']?.toString() ?? '—'),
          cell(item['vehiculoPlaca']?.toString() ?? '—'),
          cell(displayName),
          cell(_formatDate(item['fechaEntrada']?.toString())),
        ];
      case _DashboardSection.inventario:
        return [
          cell(item['id']?.toString() ?? '—'),
          cell(item['nombre']?.toString() ?? '—'),
          cell(item['marca']?.toString() ?? '—'),
          cell(item['categoria']?.toString() ?? '—'),
          cell(item['stock']?.toString() ?? '—'),
          cell(item['stockMinimo']?.toString() ?? '—'),
        ];
      case _DashboardSection.inicio:
        return [];
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final date = DateTime.parse(raw);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
            icon: Icons.directions_car_rounded,
            label: 'Vehículos',
            value: '$_vehiculos'),
        _statCard(
            icon: Icons.build_rounded,
            label: 'Órdenes activas',
            value: '$_activas',
            iconColor: _kWarning,
            highlight: true),
        _statCard(
            icon: Icons.check_circle_outline,
            label: 'Finalizadas',
            value: '$_finalizadas',
            iconColor: _kSuccess),
        _statCard(
            icon: Icons.request_quote_rounded,
            label: 'Cotizaciones',
            value: '$_cotizaciones'),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _kAccent,
    bool highlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: highlight ? _kWarning : _kBorder,
            width: highlight ? 1.2 : 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(value,
                  style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Text(label,
              style: const TextStyle(
                  color: _kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: _kAccent, size: 12),
                    SizedBox(width: 4),
                    Text('EN CURSO',
                        style: TextStyle(
                            color: _kAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    color: Color(0xFF1E3048), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_activas órdenes activas',
                        style: const TextStyle(
                            color: _kTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('$_finalizadas finalizadas',
                        style: const TextStyle(
                            color: _kTextSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: _kBorder, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.request_quote_rounded, color: _kAccent, size: 16),
              const SizedBox(width: 8),
              Text('$_cotizaciones cotizaciones pendientes',
                  style: const TextStyle(color: _kTextPrimary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.directions_car_rounded, color: _kSuccess, size: 16),
              const SizedBox(width: 8),
              Text('$_vehiculos vehículos registrados',
                  style: const TextStyle(color: _kTextPrimary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      backgroundColor: _kBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cuenta',
                      style: TextStyle(
                          color: _kAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  FutureBuilder<String?>(
                    future: _getInitials(),
                    builder: (context, snap) {
                      final initials = snap.data ?? '?';
                      return Row(
                        children: [
                          CircleAvatar(
                              radius: 22,
                              backgroundColor: _kBorder,
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: _kTextPrimary,
                                      fontWeight: FontWeight.w700))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text('Usuario',
                                  style: const TextStyle(
                                      color: _kTextPrimary,
                                      fontWeight: FontWeight.w600))),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: _kBorder),
            ListTile(
              leading: const Icon(Icons.settings, color: _kTextPrimary),
              title: const Text('Configuración',
                  style: TextStyle(color: _kTextPrimary)),
              onTap: () {
                Navigator.of(context).maybePop();
                // TODO: open configuración page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: _kTextPrimary),
              title:
                  const Text('Salir', style: TextStyle(color: _kTextPrimary)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getInitials() async {
    final token = await ref.read(secureStorageProvider).getAccessToken();
    return _extractInitialsFromToken(token);
  }

  String? _extractInitialsFromToken(String? token) {
    if (token == null) return null;
    try {
      final payload = JwtDecoder.decodePayload(token);
      String? nombres;
      String? apellidos;
      if (payload.containsKey('nombres'))
        nombres = payload['nombres'] as String?;
      if (payload.containsKey('nombre'))
        nombres = payload['nombre'] as String? ?? nombres;
      if (payload.containsKey('apellidos'))
        apellidos = payload['apellidos'] as String?;
      if (payload.containsKey('apellido'))
        apellidos = payload['apellido'] as String? ?? apellidos;
      if (nombres == null && apellidos == null) return null;
      final firstName = (nombres ?? '')
          .split(' ')
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      final firstLast = (apellidos ?? '')
          .split(' ')
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      final a = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
      final b = firstLast.isNotEmpty ? firstLast[0].toUpperCase() : '';
      final combined = (a + b).isNotEmpty ? (a + b) : null;
      return combined;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final refresh = await storage.getRefreshToken();
      if (refresh != null) {
        await authRepo.logout(refresh);
      }
    } catch (_) {
      // ignore errors - proceed to clear tokens anyway
    } finally {
      await ref.read(secureStorageProvider).deleteTokens();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.replace('/login');
    }
  }
}
