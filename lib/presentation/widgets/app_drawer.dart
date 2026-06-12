import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/providers/locale_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProv    = Provider.of<ThemeProvider>(context);
    final localeProv   = Provider.of<LocaleProvider>(context);
    final user         = authProvider.currentUser;

    // Colores reactivos al modo actual
    final isDark       = themeProv.isDark;
    final drawerBg     = isDark ? const Color(0xFF1A1625) : const Color(0xFFFFF8FA);
    final headerBg     = isDark ? const Color(0xFF26203A) : const Color(0xFFFFF0F4);
    final textColor    = isDark ? const Color(0xFFF0E8EC) : AppColors.textPrimary;
    final subtextColor = isDark ? const Color(0xFFAA99A2) : AppColors.textSecondary;
    final dividerColor = isDark ? const Color(0xFF3D3050) : AppColors.borderSoft;
    final iconColor    = isDark ? const Color(0xFFD9A5B3) : AppColors.primaryDark;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              color: headerBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Usuario',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'usuario@ufpso.edu.co',
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  ),
                ],
              ),
            ),

            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 8),

            // ── Inicio ──────────────────────────────────────────
            ListTile(
              leading: Icon(Icons.home_outlined, color: iconColor),
              title: Text(
                'Gasto',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRouter.home);
              },
            ),

            Divider(color: dividerColor, height: 1),

            const Spacer(),

            // ── Salir ────────────────────────────────────────────
            Divider(color: dividerColor, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: Text(
                localeProv.t('logout'),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
