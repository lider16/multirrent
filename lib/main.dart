import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_provider.dart';
import 'controllers/product_provider.dart';
import 'controllers/order_provider.dart';
import 'services/product_service.dart';
import 'services/local_storage_service.dart';
import 'services/deduplication_service.dart';
import 'services/sync_service.dart';
import 'models/order_model.dart';
import 'models/product_model.dart';
import 'models/selected_product.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SelectedProductAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  await Supabase.initialize(
    url: 'https://sbtnmxychihrxnqxvrym.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidG5teHljaGlocnhucXh2cnltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxMjc0ODMsImV4cCI6MjA3NTcwMzQ4M30.f9Nt9fPJh6l5eAdpi_6yknfyLY5Q1XSw9fI1M53M3oU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            ProductService(),
            LocalStorageService(),
            DeduplicationService(LocalStorageService()),
            SyncService(
              ProductService(),
              LocalStorageService(),
              DeduplicationService(LocalStorageService()),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MultirrentOperaciones',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
