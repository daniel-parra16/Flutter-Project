import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inno/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_inno/core/utils/jwt_decoder.dart';
import 'package:flutter_inno/core/network/providers.dart';

class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  static const _kBg = Color(0xFF0F1923);
  static const _kCard = Color(0xFF152030);
  static const _kBorder = Color(0xFF1E3048);
  static const _kAccent = Color(0xFF3B9EFF);
  static const _kTextPrimary = Color(0xFFF0F6FF);

  Future<String?> _getInitials() async {
    final token = await ref.read(secureStorageProvider).getAccessToken();
    try {
      if (token == null) return null;
      final payload = JwtDecoder.decodePayload(token);
      String? nombres =
          payload['nombres'] as String? ?? payload['nombre'] as String?;
      String? apellidos =
          payload['apellidos'] as String? ?? payload['apellido'] as String?;
      final a = (nombres?.isNotEmpty ?? false)
          ? nombres!.split(' ').first[0].toUpperCase()
          : '';
      final b = (apellidos?.isNotEmpty ?? false)
          ? apellidos!.split(' ').first[0].toUpperCase()
          : '';
      final combined = (a + b).isNotEmpty ? (a + b) : null;
      return combined;
    } catch (_) {
      return null;
    }
  }

  final GlobalKey _avatarKey = GlobalKey();

  Future<void> _handleLogout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final refresh = await storage.getRefreshToken();
      if (refresh != null) await authRepo.logout(refresh);
    } catch (_) {}
    await ref.read(secureStorageProvider).deleteTokens();
    if (!mounted) return;
    context.replace('/login');
  }

  @override
  Widget build(BuildContext context) {
    final location = Uri.base.path;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        title: Text(
          'InnoGarage',
          style: const TextStyle(
              color: _kTextPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          GestureDetector(
            key: _avatarKey,
            onTap: () async {
              final renderBox =
                  _avatarKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              final overlay =
                  Overlay.of(context)!.context.findRenderObject() as RenderBox;
              final size = renderBox.size;
              final offset = renderBox.localToGlobal(Offset.zero);
              final left = offset.dx;
              final top = offset.dy + size.height + 6; // small gap below avatar
              final right = overlay.size.width - (left + size.width);
              final bottom = overlay.size.height - top;
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(left, top, right, bottom),
                items: [
                  PopupMenuItem(
                      value: 'config',
                      child: Row(children: const [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Configuración')
                      ])),
                  PopupMenuItem(
                      value: 'logout',
                      child: Row(children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Salir')
                      ])),
                ],
              );
              if (selected == 'logout') await _handleLogout();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FutureBuilder<String?>(
                future: _getInitials(),
                builder: (context, snap) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: _kBorder,
                    child: Text(snap.data ?? '?',
                        style: const TextStyle(
                            color: _kTextPrimary, fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _kBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: _kBorder, width: 1))),
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
                          style: TextStyle(
                              color: Color(0xFF5A7A9A), fontSize: 13)),
                    ]),
              ),
              Expanded(
                  child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                    _drawerItemWidget(context, location, 'Dashboard',
                        '/dashboard', Icons.dashboard_rounded),
                    _drawerItemWidget(context, location, 'Usuarios',
                        '/usuarios', Icons.people_rounded),
                    _drawerItemWidget(context, location, 'Vehículos',
                        '/vehiculos', Icons.directions_car_rounded),
                    _drawerItemWidget(context, location, 'Agendamientos',
                        '/agendamientos', Icons.event_note_rounded),
                    _drawerItemWidget(context, location, 'Cotizaciones',
                        '/cotizaciones', Icons.request_quote_rounded),
                    _drawerItemWidget(context, location, 'Órdenes', '/ordenes',
                        Icons.build_circle_rounded),
                    _drawerItemWidget(context, location, 'Inventario',
                        '/inventario', Icons.inventory_2_rounded),
                  ])),
            ],
          ),
        ),
      ),
      body: SafeArea(
          child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: widget.child)),
    );
  }

  Widget _drawerItemWidget(BuildContext context, String location, String label,
      String route, IconData icon) {
    final active = location == route || location.startsWith(route + '/');
    return ListTile(
      leading: Icon(icon, color: active ? _kAccent : const Color(0xFF5A7A9A)),
      title: Text(label,
          style: TextStyle(
              color: active ? _kAccent : _kTextPrimary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      tileColor: active ? const Color(0xFF132039) : Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
