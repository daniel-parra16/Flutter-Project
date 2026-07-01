import 'package:flutter/material.dart';

typedef Fetcher = Future<List<Map<String, dynamic>>> Function(
    {String? search, String? rol, String? estado});

class ModuleBase extends StatefulWidget {
  final String title;
  final Fetcher fetcher;
  final List<DataColumn> Function() columnsBuilder;
  final List<DataRow> Function(List<Map<String, dynamic>>) rowsBuilder;
  final bool showRole;
  final bool showState;

  const ModuleBase({
    super.key,
    required this.title,
    required this.fetcher,
    required this.columnsBuilder,
    required this.rowsBuilder,
    this.showRole = false,
    this.showState = false,
  });

  @override
  State<ModuleBase> createState() => _ModuleBaseState();
}

class _ModuleBaseState extends State<ModuleBase> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedState;
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];
  String? _error;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.fetcher(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          rol: _selectedRole,
          estado: _selectedState);
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando datos';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style: const TextStyle(
                color: Color(0xFF3B9EFF),
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFF152030),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E3048))),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _load(),
                  style: const TextStyle(color: Color(0xFFF0F6FF)),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Color(0xFF5A7A9A)),
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Color(0xFF5A7A9A))),
                ),
              ),
              if (widget.showRole)
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    onChanged: (v) {
                      setState(() {
                        _selectedRole = v;
                      });
                      _load();
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos'))
                    ],
                  ),
                ),
              if (widget.showState)
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    onChanged: (v) {
                      setState(() {
                        _selectedState = v;
                      });
                      _load();
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos'))
                    ],
                  ),
                ),
              ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B9EFF)),
                  child: const Text('Consultar')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B9EFF))),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (!_loading && _items.isEmpty)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No se encontraron registros.',
                  style: TextStyle(color: Color(0xFF5A7A9A)))),
        if (_items.isNotEmpty)
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  columns: widget.columnsBuilder(),
                  rows: widget.rowsBuilder(_items))),
      ],
    );
  }
}
