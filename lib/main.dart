import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'data/services/session_service.dart';
import 'data/services/api_service.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/locale_provider.dart';
import 'presentation/auth/login/login_page.dart';
import 'presentation/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        Provider<SessionService>.value(value: sessionService),
        Provider<ApiService>.value(value: apiService),
        // ── NUEVOS: tema e idioma ──────────────────────────────
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        // ── Existentes sin cambios ─────────────────────────────
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiService, sessionService)..checkSession(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(apiService),
        ),
      ],
      // Consumer2 para que MaterialApp reaccione a ambos toggles
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (_, themeProv, localeProv, __) => MaterialApp(
          title: localeProv.t('app_title'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProv.themeMode,
          locale: localeProv.locale,
          home: const AuthGate(),
          routes: AppRouter.routes,
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.initialized) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.white70,
              ),
            ],
          ),
        ),
      );
    }

    return auth.isAuthenticated ? const HomePage() : const LoginPage();
  }
}
