import 'package:flutter/material.dart';

class InicioModule extends StatelessWidget {
  const InicioModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Resumen',
            style: TextStyle(
                color: Color(0xFF3B9EFF),
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Text('Contenido del dashboard principal...',
            style: TextStyle(color: Color(0xFFF0F6FF))),
      ],
    );
  }
}
