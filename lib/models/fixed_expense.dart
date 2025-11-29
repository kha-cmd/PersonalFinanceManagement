class FixedExpense {
  int? id;
  String category;
  String type;
  double amount;
  String status;   // obligation or essential
  String date;     // NEW: store date as text (YYYY-MM-DD)

  FixedExpense({
    this.id,
    required this.category,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
  });

  // Convert model → Map (SQLite insert)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'amount': amount,
      'status': status,
      'date': date,
    };
  }

  // Convert SQLite Map → model
  factory FixedExpense.fromMap(Map<String, dynamic> m) {
    return FixedExpense(
      id: m['id'] is int ? m['id'] : int.tryParse(m['id'].toString()),
      category: m['category'],
      type: m['type'],
      amount: (m['amount'] as num).toDouble(),
      status: m['status'],
      date: m['date'], // NEW
    );
  }
}
