import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_ocr/services/receipt_parser.dart';
import 'package:expense_tracker_ocr/services/sample_receipts_data.dart';
import 'package:expense_tracker_ocr/models/expense_category.dart';

void main() {
  group('ReceiptParser Regex Heuristics Engine Tests', () {
    test('Test WinMart+ receipt parsing', () {
      final sample = SampleReceiptsData.samples[0];
      final parsed = ReceiptParser.parse(sample.rawOcrText);

      expect(parsed.merchant, contains('WinMart'));
      expect(parsed.totalAmount, equals(154000.0));
      expect(parsed.date.day, equals(10));
      expect(parsed.date.month, equals(10));
      expect(parsed.date.year, equals(2026));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.food));
    });

    test('Test Highlands Coffee receipt parsing', () {
      final sample = SampleReceiptsData.samples[1];
      final parsed = ReceiptParser.parse(sample.rawOcrText);

      expect(parsed.merchant, equals('Highlands Coffee'));
      expect(parsed.totalAmount, equals(118000.0));
      expect(parsed.date.day, equals(9));
      expect(parsed.date.month, equals(10));
      expect(parsed.date.year, equals(2026));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.food));
    });

    test('Test Fahasa Bookstore receipt parsing', () {
      final sample = SampleReceiptsData.samples[2];
      final parsed = ReceiptParser.parse(sample.rawOcrText);

      expect(parsed.merchant, equals('Nhà Sách Fahasa'));
      expect(parsed.totalAmount, equals(235000.0));
      expect(parsed.date.day, equals(7));
      expect(parsed.date.month, equals(10));
      expect(parsed.date.year, equals(2026));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.study));
    });

    test('Test Petrolimex fuel receipt parsing', () {
      final sample = SampleReceiptsData.samples[3];
      final parsed = ReceiptParser.parse(sample.rawOcrText);

      expect(parsed.merchant, equals('Petrolimex'));
      expect(parsed.totalAmount, equals(90000.0));
      expect(parsed.date.day, equals(5));
      expect(parsed.date.month, equals(10));
      expect(parsed.date.year, equals(2026));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.travel));
    });

    test('Test Phong Vũ gear receipt parsing', () {
      final sample = SampleReceiptsData.samples[4];
      final parsed = ReceiptParser.parse(sample.rawOcrText);

      expect(parsed.merchant, equals('Phong Vũ'));
      expect(parsed.totalAmount, equals(320000.0));
      expect(parsed.date.day, equals(3));
      expect(parsed.date.month, equals(10));
      expect(parsed.date.year, equals(2026));
      expect(parsed.suggestedCategory, equals(ExpenseCategory.gear));
    });
  });
}
