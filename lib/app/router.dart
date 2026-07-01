import 'package:go_router/go_router.dart';
import 'package:flutter_inno/features/auth/auth.dart';
import 'package:flutter_inno/features/dashboard/presentation/widgets/dashboard_shell.dart';
import 'package:flutter_inno/features/dashboard/presentation/modules/inicio_module.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/usuarios_page.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/vehiculos_page.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/agendamientos_page.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/cotizaciones_page.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/ordenes_page.dart';
import 'package:flutter_inno/features/dashboard/presentation/pages/inventario_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [
        GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const InicioModule()),
        GoRoute(
            path: '/usuarios',
            name: 'usuarios',
            builder: (context, state) => const UsuariosPage()),
        GoRoute(
            path: '/vehiculos',
            name: 'vehiculos',
            builder: (context, state) => const VehiculosPage()),
        GoRoute(
            path: '/agendamientos',
            name: 'agendamientos',
            builder: (context, state) => const AgendamientosPage()),
        GoRoute(
            path: '/cotizaciones',
            name: 'cotizaciones',
            builder: (context, state) => const CotizacionesPage()),
        GoRoute(
            path: '/ordenes',
            name: 'ordenes',
            builder: (context, state) => const OrdenesPage()),
        GoRoute(
            path: '/inventario',
            name: 'inventario',
            builder: (context, state) => const InventarioPage()),
      ],
    ),
  ],
);
