import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clever_realtor/provider/graphql_config.dart';
import 'package:clever_realtor/screens/clients_screen.dart';
import 'package:clever_realtor/screens/settings_screen.dart'; // Add this import
import 'package:clever_realtor/services/logger_service.dart';
import 'package:provider/provider.dart';
import 'package:clever_realtor/provider/theme_provider.dart';
import 'package:clever_realtor/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  LoggerService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GraphQLProvider(
      client: GraphQLConfig.initializeClient(),
      child: MaterialApp(
        title: 'Clever Realtor',
        theme: ThemeData(
          useMaterial3: themeProvider.useMaterial3,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ).copyWith(
            surface: Colors.white,
            background: const Color(0xFFF5F5F5),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: themeProvider.useMaterial3,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ).copyWith(
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: const Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: Routes.home,
        routes: {
          Routes.home: (context) => const ClientsScreen(),
          Routes.settings: (context) => SettingsScreen(
                isDarkMode: themeProvider.isDarkMode,
                onThemeToggle: themeProvider.toggleTheme,
                useMaterial3: themeProvider.useMaterial3,
                onMaterial3Toggle: themeProvider.toggleMaterial3,
              ),
        },
      ),
    );
  }
}
