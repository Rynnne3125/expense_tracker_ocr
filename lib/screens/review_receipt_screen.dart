import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/parsed_receipt.dart';
import '../providers/expense_provider.dart';

class ReviewReceiptScreen extends StatefulWidget {
  final ParsedReceipt parsedReceipt;

  const ReviewReceiptScreen({
    super.key,
    required this.parsedReceipt,
  });

  @override
  State<ReviewReceiptScreen> createState() => _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends State<ReviewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  bool _showRawText = false;

  @override
  void initState() {
    super.initState();
    final receipt = widget.parsedReceipt;

    _merchantController = TextEditingController(text: receipt.merchant);
    _titleController = TextEditingController(
      text: receipt.merchant.isNotEmpty ? 'Chi tiêu tại ${receipt.merchant}' : 'Chi tiêu hóa đơn',
    );
    _amountController = TextEditingController(
      text: receipt.totalAmount > 0
          ? NumberFormat('#,###', 'vi_VN').format(receipt.totalAmount.round())
          : '',
    );
    _notesController = TextEditingController(
      text: receipt.lineItems.isNotEmpty
          ? receipt.lineItems.map((e) => '${e.name} (x${e.quantity})').join(', ')
          : '',
    );
    _selectedDate = receipt.date;
    _selectedCategory = receipt.suggestedCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final rawAmountText = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(rawAmountText) ?? 0.0;

    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      merchant: _merchantController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      receiptImagePath: widget.parsedReceipt.imagePath,
      rawOcrText: widget.parsedReceipt.rawText,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    context.read<ExpenseProvider>().addExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã lưu hóa đơn "${expense.merchant}" thành công!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Pop back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final receipt = widget.parsedReceipt;
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kiểm tra hóa đơn OCR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Lưu hóa đơn',
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Receipt Thumbnail / Confidence Tag
              Card(
                elevation: 0,
                color: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFA5D6A7)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 54,
                          height: 54,
                          color: Colors.white,
                          child: widget.parsedReceipt.imagePath != null &&
                                  !kIsWeb &&
                                  File(widget.parsedReceipt.imagePath!).existsSync()
                              ? Image.file(
                                  File(widget.parsedReceipt.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 32,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Google ML Kit OCR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${((receipt.amountConfidence) * 100).toInt()}% tin cậy',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đã nhận diện tự động bằng Regex Heuristics. Bạn có thể chỉnh sửa trước khi lưu.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Total Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
                decoration: InputDecoration(
                  labelText: 'Tổng số tiền (VND) *',
                  labelStyle: const TextStyle(fontSize: 15),
                  prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFFD32F2F)),
                  suffixText: '₫',
                  suffixStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final clean = val.replaceAll(RegExp(r'[^\d]'), '');
                  if (clean.isEmpty || (double.tryParse(clean) ?? 0) <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  return null;
                },
              ),

              // Candidate amounts chips (if multiple numbers detected)
              if (receipt.candidateAmounts.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Các số tiền khác tìm thấy trong hóa đơn:',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: receipt.candidateAmounts.take(4).map((amt) {
                    return ActionChip(
                      label: Text(
                        currencyFormatter.format(amt),
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        setState(() {
                          _amountController.text =
                              NumberFormat('#,###', 'vi_VN').format(amt.round());
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              // Merchant Name Field
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: 'Cửa hàng / Người bán *',
                  prefixIcon: const Icon(Icons.storefront_rounded),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (val) {
                  if (_titleController.text.startsWith('Chi tiêu tại ') ||
                      _titleController.text == 'Chi tiêu hóa đơn') {
                    _titleController.text = 'Chi tiêu tại $val';
                  }
                },
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
              ),

              const SizedBox(height: 14),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nội dung chi tiêu *',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),

              const SizedBox(height: 14),

              // Date Picker Field
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày giao dịch',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Selector
              const Text(
                'Danh mục phân loại:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.viName),
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    selected: isSelected,
                    selectedColor: cat.color,
                    backgroundColor: cat.color.withValues(alpha: 0.08),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? cat.color : cat.color.withValues(alpha: 0.3),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú / Các món đã mua',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle Raw OCR Text Preview
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _showRawText = !_showRawText),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        _showRawText ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showRawText ? 'Ẩn văn bản OCR gốc' : 'Xem văn bản OCR gốc trích xuất',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showRawText) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    receipt.rawText.isNotEmpty
                        ? receipt.rawText
                        : '(Không có văn bản OCR)',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveExpense,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Xác nhận & Lưu vào sổ thu chi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
