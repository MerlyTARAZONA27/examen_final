import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locale_provider.dart';
import '../../../data/providers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Lógica de login: sin cambios ──────────────────────────────
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final locale       = Provider.of<LocaleProvider>(context);
    final themeProv    = Provider.of<ThemeProvider>(context);
    final size         = MediaQuery.of(context).size;
    final theme        = Theme.of(context);
    final isDark       = theme.brightness == Brightness.dark;

    final cardBg  = isDark ? const Color(0xFF26203A) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF2E2845) : const Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [

                // ── Fondo superior con gradiente ──────────────
                Container(
                  height: size.height * 0.38,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2E1F3A), const Color(0xFF4A2D5A)]
                          : [AppColors.primary, const Color(0xFFB6E0FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // ── Decoración suave ──────────────────────────
                Positioned(
                  top: 50,
                  left: -40,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white.withOpacity(0.15),
                  ),
                ),
                Positioned(
                  top: 120,
                  right: -30,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.accent.withOpacity(0.3),
                  ),
                ),

                // ── BOTONES DE TOGGLE (esquina superior derecha) ──
                Positioned(
                  top: 10,
                  right: 12,
                  child: Row(
                    children: [
                      // Toggle idioma
                      _ToggleButton(
                        onTap: () => locale.toggle(),
                        child: Text(
                          locale.isSpanish ? '🇨🇴 ES' : '🇺🇸 EN',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle tema
                      _ToggleButton(
                        onTap: () => themeProv.toggle(),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Encabezado ────────────────────────────────
                Positioned(
                  top: 90,
                  left: 30,
                  right: 30,
                  child: Column(
                    children: [
                      const Icon(Icons.savings_rounded, size: 70, color: Colors.white),
                      const SizedBox(height: 15),
                      Text(
                        locale.t('welcome'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale.t('login_sub'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // ── Card del login ────────────────────────────
                Positioned(
                  top: size.height * 0.32,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 35,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.only(
                        topLeft:  Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: locale.t('email_hint'),
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: fieldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return locale.t('enter_email');
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return locale.t('invalid_email');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: locale.t('password_hint'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return locale.t('enter_password');
                              if (value.length < 6) return locale.t('min_6_chars');
                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          // Botón login
                          SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: authProvider.isLoading ? null : _submit,
                              child: authProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      locale.t('sign_in'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRouter.register),
                              child: Text(
                                locale.t('create_account_link'),
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(locale.t('feature_unavail'))),
                                );
                              },
                              child: Text(locale.t('forgot_password')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget auxiliar: botón pill transparente ──────────────────────
class _ToggleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ToggleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
        ),
        child: child,
      ),
    );
  }
}
