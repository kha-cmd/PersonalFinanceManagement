class Income {
  int? id;
  double totalIncome;
  String date; // ISO string

  Income({this.id, required this.totalIncome, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_income': totalIncome,
      'date': date,
    };
  }

  factory Income.fromMap(Map<String, dynamic> m) {
    return Income(
      id: m['id'] as int?,
      totalIncome: (m['total_income'] as num).toDouble(),
      date: m['date'] as String,
    );
  }
}