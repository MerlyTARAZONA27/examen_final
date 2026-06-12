import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale_code';
  Locale _locale = const Locale('es');

  Locale get locale => _locale;
  bool get isSpanish => _locale.languageCode == 'es';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'es';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> toggle() async {
    _locale = isSpanish ? const Locale('en') : const Locale('es');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _locale.languageCode);
  }

  // Traducciones inline — sin paquete externo
  String t(String key) =>
      (_strings[_locale.languageCode] ?? _strings['es']!)[key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    'es': {
      // Auth
      'welcome'            : 'Bienvenido',
      'login_sub'          : 'Inicia sesión para continuar',
      'email_hint'         : 'Correo electrónico',
      'password_hint'      : 'Contraseña',
      'sign_in'            : 'Iniciar sesión',
      'create_account_link': 'Crear cuenta',
      'forgot_password'    : '¿Olvidaste tu contraseña?',
      'feature_unavail'    : 'Función no disponible',
      'enter_email'        : 'Ingresa tu correo',
      'invalid_email'      : 'Correo inválido',
      'enter_password'     : 'Ingresa tu contraseña',
      'min_6_chars'        : 'Mínimo 6 caracteres',
      // Register
      'create_account'     : 'Crear Cuenta',
      'register_sub'       : 'Regístrate para comenzar',
      'full_name'          : 'Nombre completo',
      'confirm_password'   : 'Confirmar contraseña',
      'already_account'    : '¿Ya tienes cuenta? Inicia sesión',
      'enter_name'         : 'Ingresa tu nombre',
      'min_3_chars'        : 'Mínimo 3 caracteres',
      'pwd_no_match'       : 'Las contraseñas no coinciden',
      'reg_ok_title'       : 'Registro Exitoso',
      'reg_ok_body'        : 'Tu cuenta ha sido creada exitosamente. Presiona continuar para iniciar sesión.',
      'continue_btn'       : 'Continuar',
      // Home
      'app_title'          : 'Gasto',
      'total_balance'      : 'Balance Total',
      'income_label'       : 'Ingresos',
      'expense_label'      : 'Gastos',
      'no_movements'       : 'No existen movimientos',
      'add_movement'       : 'Movimiento',
      'snack_deleted'      : 'Gasto Eliminado',
      // Drawer
      'nav_home'           : 'Gasto',
      'logout'             : 'Salir',
      'dark_mode'          : 'Modo oscuro',
      'language'           : 'Idioma',
      // Form
      'new_movement'       : 'Nuevo Movimiento',
      'edit_movement'      : 'Editar Movimiento',
      'new_movement_sub'   : 'Registra un ingreso o un gasto',
      'edit_movement_sub'  : 'Actualiza la información del movimiento',
      'movement_type'      : 'Tipo de movimiento',
      'income_type'        : 'Ingreso',
      'expense_type'       : 'Gasto',
      'description'        : 'Descripción',
      'salary_hint'        : 'Salario',
      'food_hint'          : 'Comida',
      'value'              : 'Valor',
      'enter_desc'         : 'Ingresa una descripción',
      'enter_value'        : 'Ingresa un valor',
      'invalid_amount'     : 'Ingresa un monto válido mayor a 0',
      'save_movement'      : 'Guardar Movimiento',
      'update_movement'    : 'Actualizar Movimiento',
      'snack_inserted'     : 'Gasto Insertado',
      'snack_updated'      : 'Movimiento Actualizado',
      // Card
      'card_income'        : 'INGRESO',
      'card_expense'       : 'GASTO',
      'delete_title'       : 'Eliminar movimiento',
      'delete_body'        : '¿Estás seguro de que deseas eliminar este registro?',
      'cancel'             : 'Cancelar',
      'delete'             : 'Eliminar',
      'edit'               : 'Editar',
    },
    'en': {
      'welcome'            : 'Welcome',
      'login_sub'          : 'Sign in to continue',
      'email_hint'         : 'Email address',
      'password_hint'      : 'Password',
      'sign_in'            : 'Sign in',
      'create_account_link': 'Create account',
      'forgot_password'    : 'Forgot your password?',
      'feature_unavail'    : 'Feature not available',
      'enter_email'        : 'Enter your email',
      'invalid_email'      : 'Invalid email',
      'enter_password'     : 'Enter your password',
      'min_6_chars'        : 'Minimum 6 characters',
      'create_account'     : 'Create Account',
      'register_sub'       : 'Sign up to get started',
      'full_name'          : 'Full name',
      'confirm_password'   : 'Confirm password',
      'already_account'    : 'Already have an account? Sign in',
      'enter_name'         : 'Enter your name',
      'min_3_chars'        : 'Minimum 3 characters',
      'pwd_no_match'       : 'Passwords do not match',
      'reg_ok_title'       : 'Registration Successful',
      'reg_ok_body'        : 'Your account was created. Press continue to sign in.',
      'continue_btn'       : 'Continue',
      'app_title'          : 'Budget',
      'total_balance'      : 'Total Balance',
      'income_label'       : 'Income',
      'expense_label'      : 'Expenses',
      'no_movements'       : 'No movements yet',
      'add_movement'       : 'Movement',
      'snack_deleted'      : 'Entry Deleted',
      'nav_home'           : 'Budget',
      'logout'             : 'Sign out',
      'dark_mode'          : 'Dark mode',
      'language'           : 'Language',
      'new_movement'       : 'New Entry',
      'edit_movement'      : 'Edit Entry',
      'new_movement_sub'   : 'Record an income or expense',
      'edit_movement_sub'  : 'Update entry information',
      'movement_type'      : 'Entry type',
      'income_type'        : 'Income',
      'expense_type'       : 'Expense',
      'description'        : 'Description',
      'salary_hint'        : 'Salary',
      'food_hint'          : 'Food',
      'value'              : 'Amount',
      'enter_desc'         : 'Enter a description',
      'enter_value'        : 'Enter an amount',
      'invalid_amount'     : 'Enter a valid amount greater than 0',
      'save_movement'      : 'Save Entry',
      'update_movement'    : 'Update Entry',
      'snack_inserted'     : 'Entry Added',
      'snack_updated'      : 'Entry Updated',
      'card_income'        : 'INCOME',
      'card_expense'       : 'EXPENSE',
      'delete_title'       : 'Delete entry',
      'delete_body'        : 'Are you sure you want to delete this record?',
      'cancel'             : 'Cancel',
      'delete'             : 'Delete',
      'edit'               : 'Edit',
    },
  };
}
