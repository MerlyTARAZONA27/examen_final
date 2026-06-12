import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';

class ApiService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // --- USUARIOS (MockAPI) ---

  Future<UserModel> registerUser(UserModel user) async {
    const baseUrl = AppConstants.mockApiUrl;
    final checkUri = Uri.parse('$baseUrl/users');
    debugPrint('[ApiService] GET check email -> $checkUri');
    try {
      final responseCheck = await http.get(checkUri, headers: _headers);
      if (responseCheck.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(responseCheck.body);
        final emailExists = usersJson.any((u) =>
            u['email']?.toString().toLowerCase() == user.email.toLowerCase());
        if (emailExists) {
          throw Exception('El correo electrónico ya está registrado.');
        }
      }
    } catch (e) {
      if (e.toString().contains('El correo electrónico')) rethrow;
    }

    final uri = Uri.parse('$baseUrl/users');
    debugPrint('[ApiService] POST register user -> $uri');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }

  Future<UserModel> loginUser(String email, String password) async {
    const baseUrl = AppConstants.mockApiUrl;
    final uri = Uri.parse('$baseUrl/users');
    debugPrint('[ApiService] GET login user -> $uri');

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      for (var u in usersJson) {
        final currentEmail = u['email']?.toString().toLowerCase();
        final currentPassword = u['password']?.toString();
        if (currentEmail == email.toLowerCase() && currentPassword == password) {
          return UserModel.fromJson(u);
        }
      }
      throw Exception('Credenciales incorrectas o usuario no encontrado.');
    } else {
      throw Exception('Error al conectar con el servidor: ${response.statusCode}');
    }
  }

  // --- TRANSACCIONES (SQLite local) ---

  Future<List<TransactionModel>> getTransactions() async {
    debugPrint('[ApiService] GET transactions from SQLite');
    return await _dbHelper.getTransactions();
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    debugPrint('[ApiService] POST create transaction in SQLite: ${transaction.title}');
    return await _dbHelper.insertTransaction(transaction);
  }

  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    debugPrint('[ApiService] PUT update transaction in SQLite: ${transaction.id}');
    return await _dbHelper.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    debugPrint('[ApiService] DELETE transaction in SQLite: $id');
    await _dbHelper.deleteTransaction(id);
  }
}
