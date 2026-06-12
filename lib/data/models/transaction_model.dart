class TransactionModel {
  final String? id;
  final DateTime? createdAt;
  final String title;
  final double amount;
  final String type; // 'income' o 'expense'
  final String? userId;

  TransactionModel({
    this.id,
    this.createdAt,
    required this.title,
    required this.amount,
    required this.type,
    this.userId,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      parsedAmount = double.tryParse(json['amount'].toString()) ?? 0.0;
    }

    String rawType = (json['type'] as String? ?? 'expense').toLowerCase().trim();
    String parsedType = rawType == 'income' ? 'income' : 'expense';

    return TransactionModel(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      title: json['title'] as String? ?? '',
      amount: parsedAmount,
      type: parsedType,
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'title': title,
      'amount': amount,
      'type': type,
    };
    if (id != null) data['id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (userId != null) data['userId'] = userId;
    return data;
  }
}
