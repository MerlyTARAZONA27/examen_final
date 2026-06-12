import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _key = 'transactions';

  Future<List<Map<String, dynamic>>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeAll(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<TransactionModel> insertTransaction(TransactionModel transaction) async {
    final list = await _readAll();
    final id = transaction.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final map = transaction.toJson();
    map['id'] = id;
    map['createdAt'] = (transaction.createdAt ?? DateTime.now()).toIso8601String();

    // Reemplaza si ya existe, si no agrega
    final index = list.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      list[index] = map;
    } else {
      list.add(map);
    }

    await _writeAll(list);
    return TransactionModel.fromJson(map);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final list = await _readAll();
    final models = list.map((m) => TransactionModel.fromJson(m)).toList();
    // Ordenar por fecha descendente
    models.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return models;
  }

  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw Exception('El ID de la transacción es necesario para actualizar.');
    }
    final list = await _readAll();
    final map = transaction.toJson();
    map['createdAt'] = (transaction.createdAt ?? DateTime.now()).toIso8601String();

    final index = list.indexWhere((e) => e['id'] == transaction.id);
    if (index != -1) {
      list[index] = map;
    }

    await _writeAll(list);
    return TransactionModel.fromJson(map);
  }

  Future<void> deleteTransaction(String id) async {
    final list = await _readAll();
    list.removeWhere((e) => e['id'] == id);
    await _writeAll(list);
  }
}