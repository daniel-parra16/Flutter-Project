import 'package:flutter_inno/core/network/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> getClienteDashboard(String documento) async {
    final response = await _apiClient.get(
      '/dashboard/cliente/$documento',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUsuarios(
      {String? search, String? rol}) async {
    return _fetchList(
      '/usuarios',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
        if (rol != null && rol.isNotEmpty) 'rol': rol,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getVehiculos({String? search}) async {
    return _fetchList(
      '/vehiculos',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAgendamientos(
      {String? search, String? estado}) async {
    return _fetchList(
      '/agendamientos',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCotizaciones(
      {String? search, String? estado}) async {
    return _fetchList(
      '/cotizaciones',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getOrdenes(
      {String? search, String? estado}) async {
    return _fetchList(
      '/ordenes',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getInventario({String? search}) async {
    return _fetchList(
      '/inventario',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'busqueda': search,
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.get(
      path,
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic> && data['contenido'] is List) {
      return (data['contenido'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }
}
