class DailySpend {
  int? id;
  String title;
  double amount;
  String category;
  String date;

  DailySpend({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory DailySpend.fromMap(Map<String, dynamic> map) {
    return DailySpend(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: map['date'] as String,
    );
  }
}
