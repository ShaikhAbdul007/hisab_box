class ExpenseModel {
  final String expenseName;
  final double amount;
  final String? notes;
  final String? date;
  final String? time;

  ExpenseModel({
    required this.amount,
    required this.expenseName,
    this.notes,
    this.date,
    this.time,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseName: map['expenseName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      notes: map['note'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseName': expenseName,
      'amount': amount,
      'notes': notes ?? "",
      'date': date,
      'time': time,
    };
  }
}
