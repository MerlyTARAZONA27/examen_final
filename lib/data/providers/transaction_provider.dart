import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  TransactionProvider(this._apiService);

  List<TransactionModel> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> getUserTransactions(String userId) {
    return _allTransactions.where((t) {
      return t.userId == null || t.userId == userId;
    }).toList();
  }

  double getTotalIncome(String userId) {
    return getUserTransactions(userId)
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(String userId) {
    return getUserTransactions(userId)
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalBalance(String userId) {
    return getTotalIncome(userId) - getTotalExpense(userId);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTransactions = await _apiService.getTransactions();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final txWithUser = TransactionModel(
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        createdAt: transaction.createdAt ?? DateTime.now(),
        userId: userId,
      );
      final newTx = await _apiService.createTransaction(txWithUser);
      _allTransactions.insert(0, newTx);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editTransaction(TransactionModel transaction, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final txWithUser = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        createdAt: transaction.createdAt ?? DateTime.now(),
        userId: userId,
      );
      final updatedTx = await _apiService.updateTransaction(txWithUser);
      final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _allTransactions[index] = updatedTx;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteTransaction(id);
      _allTransactions.removeWhere((t) => t.id == id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
