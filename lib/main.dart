import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inno/app/router.dart';

void main() {
  // Remove the hash (#) from web URLs when possible
  setUrlStrategy(PathUrlStrategy());

  runApp(
    const ProviderScope(
      child: InnoGarageApp(),
    ),
  );
}

class InnoGarageApp extends StatelessWidget {
  const InnoGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InnoGarage',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1923),
        primaryColor: const Color(0xFF3B9EFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B9EFF),
          onPrimary: Color(0xFFF0F6FF),
          secondary: Color(0xFF5A7A9A),
          surface: Color(0xFF152030),
          surfaceContainerHighest: Color(0xFF152030),
          onSurface: Color(0xFFF0F6FF),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF152030),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1E3048)),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3B9EFF)),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          hintStyle: TextStyle(color: Color(0xFF5A7A9A)),
          labelStyle: TextStyle(color: Color(0xFF5A7A9A)),
        ),
        useMaterial3: true,
      ),
    );
  }
}
