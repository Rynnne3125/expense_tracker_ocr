import '../models/expense_category.dart';
import '../models/parsed_receipt.dart';

class ReceiptParser {
  /// Known merchant dictionary for instant high-confidence matching
  static final List<Map<String, dynamic>> _knownMerchants = [
    // Supermarkets / Convenience
    {
      'name': 'WinMart+',
      'keywords': ['winmart', 'winmart+', 'vinmart', 'vinmart+'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Circle K',
      'keywords': ['circle k', 'circlek'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'GS25',
      'keywords': ['gs25', 'gs 25'],
      'category': ExpenseCategory.food,
    },
    {
      'name': '7-Eleven',
      'keywords': ['7-eleven', '7 eleven', '7eleven'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'FamilyMart',
      'keywords': ['familymart', 'family mart'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Bách Hóa Xanh',
      'keywords': ['bách hóa xanh', 'bach hoa xanh', 'bhx'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Co.opmart',
      'keywords': ['coopmart', 'co.opmart', 'coop mart', 'co.op food'],
      'category': ExpenseCategory.food,
    },
    // Coffee & Food
    {
      'name': 'Highlands Coffee',
      'keywords': ['highlands coffee', 'highlands', 'highland'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Phúc Long Coffee & Tea',
      'keywords': ['phúc long', 'phuc long'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'The Coffee House',
      'keywords': ['the coffee house', 'coffee house', 'tch'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Katinat Saigon Kafe',
      'keywords': ['katinat'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Phê La',
      'keywords': ['phê la', 'phe la'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Trung Nguyên Legend',
      'keywords': ['trung nguyên', 'trung nguyen'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'KFC Vietnam',
      'keywords': ['kfc'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Lotteria',
      'keywords': ['lotteria'],
      'category': ExpenseCategory.food,
    },
    {
      'name': 'Jollibee',
      'keywords': ['jollibee'],
      'category': ExpenseCategory.food,
    },
    // Bookstores & Study
    {
      'name': 'Nhà Sách Fahasa',
      'keywords': ['fahasa', 'nhà sách fahasa', 'nha sach fahasa'],
      'category': ExpenseCategory.study,
    },
    {
      'name': 'Nhà Sách Tiền Phong',
      'keywords': ['tiền phong', 'tien phong', 'nhà sách tiền phong'],
      'category': ExpenseCategory.study,
    },
    {
      'name': 'Nhà Sách Phương Nam',
      'keywords': ['phương nam', 'phuong nam', 'nhà sách phương nam'],
      'category': ExpenseCategory.study,
    },
    {
      'name': 'Photo & In Ấn VKU',
      'keywords': ['photo', 'in ấn', 'in an', 'photocopy', 'vku photo'],
      'category': ExpenseCategory.study,
    },
    // Travel & Transport
    {
      'name': 'Petrolimex',
      'keywords': ['petrolimex', 'cửa hàng xăng dầu', 'xăng dầu', 'petro'],
      'category': ExpenseCategory.travel,
    },
    {
      'name': 'PVOIL',
      'keywords': ['pvoil', 'pv oil'],
      'category': ExpenseCategory.travel,
    },
    {
      'name': 'Grab',
      'keywords': ['grab', 'grab car', 'grab bike'],
      'category': ExpenseCategory.travel,
    },
    {
      'name': 'Be Group',
      'keywords': ['be group', 'bebike', 'becar'],
      'category': ExpenseCategory.travel,
    },
    {
      'name': 'Xanh SM',
      'keywords': ['xanh sm', 'gsm'],
      'category': ExpenseCategory.travel,
    },
    // Gear & Tech
    {
      'name': 'Thế Giới Di Động',
      'keywords': ['thế giới di động', 'the gioi di dong', 'tgdd'],
      'category': ExpenseCategory.gear,
    },
    {
      'name': 'FPT Shop',
      'keywords': ['fpt shop', 'fpt'],
      'category': ExpenseCategory.gear,
    },
    {
      'name': 'CellphoneS',
      'keywords': ['cellphones', 'cellphone s'],
      'category': ExpenseCategory.gear,
    },
    {
      'name': 'Phong Vũ',
      'keywords': ['phong vũ', 'phong vu'],
      'category': ExpenseCategory.gear,
    },
    // Entertainment
    {
      'name': 'CGV Cinemas',
      'keywords': ['cgv', 'cgv cinemas'],
      'category': ExpenseCategory.entertainment,
    },
    {
      'name': 'Lotte Cinema',
      'keywords': ['lotte cinema'],
      'category': ExpenseCategory.entertainment,
    },
    {
      'name': 'Galaxy Cinema',
      'keywords': ['galaxy cinema'],
      'category': ExpenseCategory.entertainment,
    },
  ];

  /// Primary explicit keywords for Total Amount detection (highest confidence)
  static final List<String> _primaryTotalKeywords = [
    'tổng cộng',
    'tong cong',
    'tổng tiền',
    'tong tien',
    'khách phải trả',
    'khach phai tra',
    'tổng thanh toán',
    'tong thanh toan',
    'tiền thanh toán',
    'tien thanh toan',
    'phải thanh toán',
    'phai thanh toan',
    'cộng tiền hàng',
    'cong tien hang',
    'total due',
    'grand total',
    'total amount',
    'net amount',
    'balance due',
  ];

  /// Secondary fallback keywords
  static final List<String> _secondaryTotalKeywords = [
    'thành tiền',
    'thanh tien',
    'thanh toán momo',
    'thanh toan momo',
    'thanh toán:',
    'thanh toan:',
    'tiền mặt',
    'tien mat',
    'total:',
    'total',
  ];

  /// Parse the entire extracted OCR text into a structured ParsedReceipt
  static ParsedReceipt parse(String ocrText, {String? imagePath}) {
    if (ocrText.trim().isEmpty) {
      return ParsedReceipt(
        rawText: '',
        merchant: 'Cửa hàng không xác định',
        totalAmount: 0,
        date: DateTime.now(),
        suggestedCategory: ExpenseCategory.food,
        merchantConfidence: 0.1,
        amountConfidence: 0.1,
        dateConfidence: 0.1,
        imagePath: imagePath,
      );
    }

    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Extract Merchant Name
    final merchantResult = _extractMerchant(lines, ocrText);

    // 2. Extract Total Amount
    final amountResult = _extractTotalAmount(lines, ocrText);

    // 3. Extract Transaction Date
    final dateResult = _extractDate(lines, ocrText);

    // 4. Categorize based on merchant, items, and keywords
    final suggestedCategory = _detectCategory(
      merchant: merchantResult.value,
      fullText: ocrText,
      presetCategory: merchantResult.presetCategory,
    );

    // 5. Extract Line Items (if any table format matches)
    final lineItems = _extractLineItems(lines);

    return ParsedReceipt(
      rawText: ocrText,
      merchant: merchantResult.value,
      totalAmount: amountResult.value,
      date: dateResult.value,
      suggestedCategory: suggestedCategory,
      lineItems: lineItems,
      candidateAmounts: amountResult.candidates,
      merchantConfidence: merchantResult.confidence,
      amountConfidence: amountResult.confidence,
    );
  }

  /// -----------------------------------------------------------
  /// 1. MERCHANT NAME EXTRACTION HEURISTIC
  /// -----------------------------------------------------------
  static _ExtractionResult<String> _extractMerchant(
      List<String> lines, String fullText) {
    final lowerFullText = fullText.toLowerCase();

    // Strategy A: Known Brand Dictionary Matching
    for (final merchant in _knownMerchants) {
      final List<String> keywords = merchant['keywords'] as List<String>;
      for (final kw in keywords) {
        if (lowerFullText.contains(kw)) {
          return _ExtractionResult<String>(
            value: merchant['name'] as String,
            confidence: 0.95,
            presetCategory: merchant['category'] as ExpenseCategory?,
          );
        }
      }
    }

    // Strategy B: Header Heuristics (Lines 0 to 4)
    // Often receipt headers hold the store name in the first few lines.
    final genericExclusions = [
      'hóa đơn',
      'hoa don',
      'phiếu thanh toán',
      'phieu thanh toan',
      'biên lai',
      'bien lai',
      'hóa đơn bán lẻ',
      'hóa đơn gtgt',
      'phiếu thu',
      'receipt',
      'invoice',
      'tax invoice',
      'bill',
      'địa chỉ',
      'dia chi',
      'đc:',
      'dc:',
      'tel:',
      'sđt:',
      'phone:',
      'mst:',
      'mã số thuế',
      'wifi',
      'pass',
    ];

    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Skip lines matching generic header or contact info
      bool isExcluded = genericExclusions.any((ex) => lineLower.contains(ex));
      if (isExcluded) continue;

      // Skip if line is mostly digits or punctuation
      final lettersOnly = line.replaceAll(RegExp(r'[^a-zA-ZÀ-ỹ]'), '');
      if (lettersOnly.length < 3) continue;

      // Valid candidate found in header
      return _ExtractionResult<String>(
        value: line,
        confidence: 0.70,
      );
    }

    // Fallback: Default placeholder
    return _ExtractionResult<String>(
      value: lines.isNotEmpty ? lines[0] : 'Cửa hàng không xác định',
      confidence: 0.40,
    );
  }

  static bool _isNonTotalLine(String lineLower) {
    if (lineLower.startsWith('hoa don') ||
        lineLower.startsWith('hóa đơn') ||
        lineLower.startsWith('phieu thanh toan') ||
        lineLower.startsWith('phiếu thanh toán') ||
        lineLower.startsWith('bien lai') ||
        lineLower.startsWith('biên lai') ||
        lineLower.contains('thoi gian') ||
        lineLower.contains('thời gian') ||
        lineLower.contains('date:') ||
        lineLower.contains('ngày:') ||
        lineLower.contains('ngay:') ||
        lineLower.contains('ngay ban:') ||
        lineLower.contains('ngày bán:') ||
        lineLower.contains('wifi') ||
        lineLower.contains('mst:') ||
        lineLower.contains('tel:') ||
        lineLower.contains('#hd') ||
        lineLower.contains('cot bom:') ||
        lineLower.contains('cột bơm:')) {
      return true;
    }
    return false;
  }

  /// -----------------------------------------------------------
  /// 2. TOTAL AMOUNT EXTRACTION HEURISTIC
  /// -----------------------------------------------------------
  static _AmountResult _extractTotalAmount(
      List<String> lines, String fullText) {
    final List<double> candidateAmounts = [];

    // Stage 1: Primary Keywords (Explicit Total Lines)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      if (_isNonTotalLine(lineLower)) continue;

      for (final kw in _primaryTotalKeywords) {
        if (lineLower.contains(kw)) {
          final amountsInLine = _extractAmountsFromText(line);
          if (amountsInLine.isNotEmpty) {
            candidateAmounts.addAll(amountsInLine);
            return _AmountResult(
              value: amountsInLine.last,
              confidence: 0.98,
              candidates: candidateAmounts,
            );
          }

          // Check next line
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            final nextLower = nextLine.toLowerCase();
            if (!_isNonTotalLine(nextLower)) {
              final nextAmounts = _extractAmountsFromText(nextLine);
              if (nextAmounts.isNotEmpty) {
                candidateAmounts.addAll(nextAmounts);
                return _AmountResult(
                  value: nextAmounts.last,
                  confidence: 0.92,
                  candidates: candidateAmounts,
                );
              }
            }
          }
        }
      }
    }

    // Stage 2: Secondary Keywords (Payment / Subtotal)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      if (_isNonTotalLine(lineLower)) continue;

      for (final kw in _secondaryTotalKeywords) {
        if (lineLower.contains(kw)) {
          final amountsInLine = _extractAmountsFromText(line);
          if (amountsInLine.isNotEmpty) {
            candidateAmounts.addAll(amountsInLine);
            return _AmountResult(
              value: amountsInLine.last,
              confidence: 0.88,
              candidates: candidateAmounts,
            );
          }
        }
      }
    }

    // Stage 3: Scan all text for currency amounts (excluding years and dates)
    final currencyPattern = RegExp(
      r'(?:(?:\b|\s))(\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d+)?|\d{4,9})(?:\s*(?:đ|vnd|vnđ))?',
      caseSensitive: false,
    );

    final matches = currencyPattern.allMatches(fullText);
    for (final match in matches) {
      final rawNum = match.group(1);
      if (rawNum != null) {
        final parsed = _parseCleanNumber(rawNum);
        if (parsed != null && _isValidMonetaryAmount(parsed)) {
          candidateAmounts.add(parsed);
        }
      }
    }

    if (candidateAmounts.isNotEmpty) {
      candidateAmounts.sort();
      final maxAmount = candidateAmounts.last;
      return _AmountResult(
        value: maxAmount,
        confidence: 0.70,
        candidates: candidateAmounts,
      );
    }

    return _AmountResult(
      value: 0.0,
      confidence: 0.20,
      candidates: [],
    );
  }

  static bool _isValidMonetaryAmount(double num) {
    if (num < 1000 || num > 500000000) return false;
    // Discard calendar years
    if (num >= 2020 && num <= 2035) return false;
    // Discard 8-digit date timestamps YYYYMMDD (e.g. 20261009)
    final intVal = num.round();
    final strVal = intVal.toString();
    if (strVal.length == 8 && strVal.startsWith('202')) return false;
    // Discard phone numbers (10 digits starting with 0)
    if (strVal.length >= 10 && strVal.startsWith('0')) return false;
    return true;
  }

  static List<double> _extractAmountsFromText(String text) {
    final List<double> results = [];
    final pattern = RegExp(
      r'(\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d+)?|\d{4,9})(?:\s*(?:đ|vnd|vnđ))?',
      caseSensitive: false,
    );

    for (final match in pattern.allMatches(text)) {
      final raw = match.group(1);
      if (raw != null) {
        final num = _parseCleanNumber(raw);
        if (num != null && _isValidMonetaryAmount(num)) {
          results.add(num);
        }
      }
    }
    return results;
  }

  static double? _parseCleanNumber(String raw) {
    // Clean spaces, dots, commas
    // Vietnamese standard: 150.000 or 150,000
    var cleaned = raw.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    if (cleaned.isEmpty) return null;

    // If string has both dot and comma (e.g. 1,250.00 or 1.250,00)
    if (cleaned.contains('.') && cleaned.contains(',')) {
      if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
        // e.g. 1.250,50 -> 1250.50
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // e.g. 1,250.50 -> 1250.50
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains('.')) {
      // Check if dot is thousand separator: e.g. 150.000 or 1.250.000
      final parts = cleaned.split('.');
      if (parts.length > 1 && parts.last.length == 3) {
        cleaned = cleaned.replaceAll('.', '');
      } else {
        // Decimal dot e.g. 15.5
      }
    } else if (cleaned.contains(',')) {
      final parts = cleaned.split(',');
      if (parts.length > 1 && parts.last.length == 3) {
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    return double.tryParse(cleaned);
  }

  /// -----------------------------------------------------------
  /// 3. TRANSACTION DATE EXTRACTION HEURISTIC
  /// -----------------------------------------------------------
  static _ExtractionResult<DateTime> _extractDate(
      List<String> lines, String fullText) {
    // Date formats: DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY, YYYY-MM-DD
    final datePatterns = [
      // Standard DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
      RegExp(r'\b(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{4})\b'),
      // Standard DD/MM/YY
      RegExp(r'\b(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{2})\b'),
      // ISO YYYY-MM-DD
      RegExp(r'\b(\d{4})[/\.-](\d{1,2})[/\.-](\d{1,2})\b'),
      // Vietnamese: "Ngày 10 tháng 10 năm 2026"
      RegExp(r'ngày\s*(\d{1,2})\s*tháng\s*(\d{1,2})\s*năm\s*(\d{4})',
          caseSensitive: false),
    ];

    // Priority 1: Lines containing date keywords ("ngày", "date", "thời gian", "time")
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      if (lineLower.contains('ngày') ||
          lineLower.contains('date') ||
          lineLower.contains('thời gian') ||
          lineLower.contains('time') ||
          lineLower.contains('in lúc')) {
        for (final p in datePatterns) {
          final match = p.firstMatch(line);
          if (match != null) {
            final parsedDate = _resolveDateMatch(match);
            if (parsedDate != null) {
              return _ExtractionResult<DateTime>(
                value: parsedDate,
                confidence: 0.95,
              );
            }
          }
        }
      }
    }

    // Priority 2: Anywhere in the document
    for (final p in datePatterns) {
      final match = p.firstMatch(fullText);
      if (match != null) {
        final parsedDate = _resolveDateMatch(match);
        if (parsedDate != null) {
          return _ExtractionResult<DateTime>(
            value: parsedDate,
            confidence: 0.80,
          );
        }
      }
    }

    // Fallback: Current date with low confidence
    return _ExtractionResult<DateTime>(
      value: DateTime.now(),
      confidence: 0.35,
    );
  }

  static DateTime? _resolveDateMatch(Match match) {
    try {
      int day;
      int month;
      int year;

      final g1 = int.parse(match.group(1)!);
      final g2 = int.parse(match.group(2)!);
      final g3 = int.parse(match.group(3)!);

      if (g1 > 1000) {
        // YYYY-MM-DD
        year = g1;
        month = g2;
        day = g3;
      } else {
        // DD/MM/YYYY or DD/MM/YY
        day = g1;
        month = g2;
        year = g3;
        if (year < 100) {
          year += 2000;
        }
      }

      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  /// -----------------------------------------------------------
  /// 4. CATEGORY HEURISTIC DETECTION
  /// -----------------------------------------------------------
  static ExpenseCategory _detectCategory({
    required String merchant,
    required String fullText,
    ExpenseCategory? presetCategory,
  }) {
    if (presetCategory != null) return presetCategory;

    final text = '$merchant $fullText'.toLowerCase();

    // Study keywords
    if (text.contains('sách') ||
        text.contains('vở') ||
        text.contains('bút') ||
        text.contains('photo') ||
        text.contains('in ấn') ||
        text.contains('tài liệu') ||
        text.contains('giáo trình') ||
        text.contains('văn phòng phẩm') ||
        text.contains('fahasa') ||
        text.contains('tiền phong') ||
        text.contains('học phí')) {
      return ExpenseCategory.study;
    }

    // Travel keywords
    if (text.contains('xăng') ||
        text.contains('dầu') ||
        text.contains('petrolimex') ||
        text.contains('pvoil') ||
        text.contains('gửi xe') ||
        text.contains('vé xe') ||
        text.contains('grab') ||
        text.contains('be') ||
        text.contains('taxi') ||
        text.contains('xe buýt') ||
        text.contains('bus') ||
        text.contains('vé máy bay')) {
      return ExpenseCategory.travel;
    }

    // Gear & Hardware keywords
    if (text.contains('chuột') ||
        text.contains('bàn phím') ||
        text.contains('tai nghe') ||
        text.contains('cáp') ||
        text.contains('sạc') ||
        text.contains('laptop') ||
        text.contains('điện thoại') ||
        text.contains('linh kiện') ||
        text.contains('phong vũ') ||
        text.contains('fpt shop') ||
        text.contains('tgdd')) {
      return ExpenseCategory.gear;
    }

    // Entertainment keywords
    if (text.contains('phim') ||
        text.contains('cgv') ||
        text.contains('lotte cinema') ||
        text.contains('galaxy') ||
        text.contains('bida') ||
        text.contains('game') ||
        text.contains('karaoke') ||
        text.contains('vé xem') ||
        text.contains('bowling')) {
      return ExpenseCategory.entertainment;
    }

    // Default to Food & Dining (most common for daily student receipts)
    return ExpenseCategory.food;
  }

  /// -----------------------------------------------------------
  /// 5. LINE ITEMS EXTRACTION (OPTIONAL ENHANCEMENT)
  /// -----------------------------------------------------------
  static List<ReceiptLineItem> _extractLineItems(List<String> lines) {
    final List<ReceiptLineItem> items = [];
    final itemPattern = RegExp(
      r'^\s*([0-9]+[.\-)]\s*)?([A-Za-zÀ-ỹ0-9\s\-_.,]{3,30})\s+(\d+)\s+([\d.,]+)\s*$',
    );

    for (final line in lines) {
      final match = itemPattern.firstMatch(line);
      if (match != null) {
        final name = match.group(2)?.trim() ?? '';
        final qty = int.tryParse(match.group(3) ?? '1') ?? 1;
        final price = _parseCleanNumber(match.group(4) ?? '0') ?? 0.0;
        if (name.isNotEmpty && price > 0) {
          items.add(ReceiptLineItem(name: name, quantity: qty, price: price));
        }
      }
    }
    return items;
  }
}

class _ExtractionResult<T> {
  final T value;
  final double confidence;
  final ExpenseCategory? presetCategory;

  _ExtractionResult({
    required this.value,
    required this.confidence,
    this.presetCategory,
  });
}

class _AmountResult {
  final double value;
  final double confidence;
  final List<double> candidates;

  _AmountResult({
    required this.value,
    required this.confidence,
    required this.candidates,
  });
}
