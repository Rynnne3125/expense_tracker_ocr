import 'ocr_service_stub.dart'
    if (dart.library.io) 'ocr_service_native.dart'
    if (dart.library.js_interop) 'ocr_service_web.dart';

import 'ocr_service_interface.dart';
import 'receipt_parser.dart';
import '../models/parsed_receipt.dart';

class OcrService {
  static final OcrServiceInterface _service = getOcrService();

  /// Extract raw text from image file path
  static Future<String> extractText(String imagePath) async {
    return await _service.recognizeTextFromPath(imagePath);
  }

  /// High-level method: Extracts text and parses into structured ParsedReceipt
  static Future<ParsedReceipt> processReceipt(String imagePath) async {
    final rawText = await extractText(imagePath);
    return ReceiptParser.parse(rawText, imagePath: imagePath);
  }

  /// Direct method: Parse from raw text (useful for sample presets or manual paste)
  static ParsedReceipt parseFromText(String rawText, {String? imagePath}) {
    return ReceiptParser.parse(rawText, imagePath: imagePath);
  }

  static void dispose() {
    _service.dispose();
  }
}
