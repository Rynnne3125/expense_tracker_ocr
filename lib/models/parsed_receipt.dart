import 'expense_category.dart';

class ReceiptLineItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptLineItem({
    required this.name,
    this.quantity = 1,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'price': price,
      };

  factory ReceiptLineItem.fromMap(Map<String, dynamic> map) {
    return ReceiptLineItem(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ParsedReceipt {
  final String rawText;
  final String merchant;
  final double totalAmount;
  final DateTime date;
  final ExpenseCategory suggestedCategory;
  final List<ReceiptLineItem> lineItems;
  final List<double> candidateAmounts;
  final double merchantConfidence;
  final double amountConfidence;
  final double dateConfidence;
  final String? imagePath;

  ParsedReceipt({
    required this.rawText,
    required this.merchant,
    required this.totalAmount,
    required this.date,
    required this.suggestedCategory,
    this.lineItems = const [],
    this.candidateAmounts = const [],
    this.merchantConfidence = 0.8,
    this.amountConfidence = 0.85,
    this.dateConfidence = 0.9,
    this.imagePath,
  });

  bool get isHighConfidence =>
      totalAmount > 0 && merchant.isNotEmpty && amountConfidence >= 0.7;
}
