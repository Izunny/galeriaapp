import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importante
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/error_screen.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/providers/wallpaper_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/wallpaper_provider.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos para operaciones async
  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env
  await dotenv.load(fileName: ".env");

  final sharedPreferences = await SharedPreferences.getInstance();

  // aqui se configura el ErrorWidget para mostrar un error personalizado en caso de excepciones no capturadas, especialmente errores de red.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final msg = details.exceptionAsString().toLowerCase();
    final networkKeywords = [
      'socketexception',
      'failed host lookup',
      'no internet',
      'network',
      'connect',
      'handshakeexception',
      'dioerror',
      'network is unreachable',
      'failed host lookup',
      'dnslookup',
      'connection refused',
      'connection timed out',
    ];

    final isNetworkError = networkKeywords.any((k) => msg.contains(k));

    if (!isNetworkError) return ErrorWidget(details.exception);
    // Si es un error de red, mostramos una pantalla de error personalizada con opción de reintentar
    return Builder(
      builder: (context) {
        final loc = ProviderScope.containerOf(
          context,
        ).read(appLocalizationsProvider);
        return ErrorScreen(
          title: loc['offline_title'] ?? 'Sin conexión',
          message: loc['offline_desc'] ?? 'No tienes conexión a internet.',
          retryLabel: loc['retry'],
          onRetry: () {
            final container = ProviderScope.containerOf(context);
            try {
              container
                  .read(wallpaperProvider.notifier)
                  .fetchWallpapers(reset: true);
            } catch (_) {}
          },
        );
      },
    );
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    // El MaterialApp se configura para usar el tema claro u oscuro según la preferencia del usuario, y se inicia en la pantalla de splash.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GaleríaApp',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const VideoSplashScreen(), // Iniciamos en la pantalla de splash
    );
  }
}
