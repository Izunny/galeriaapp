import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importante
import 'presentation/screens/home_screen.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos para operaciones async
  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unsplash App',
      themeMode: themeMode,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: Brightness.dark),
      home: const HomeScreen(), // Iniciamos en la pantalla de inicio
    );
  }
}
