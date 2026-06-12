import 'package:flutter/material.dart';
import '../../presentation/auth/login/login_page.dart';
import '../../presentation/auth/register/register_page.dart';
import '../../presentation/home/home_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const HomePage(),
    };
  }
}
