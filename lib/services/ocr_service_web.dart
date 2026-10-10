import 'ocr_service_interface.dart';
import 'sample_receipts_data.dart';

class OcrServiceWeb implements OcrServiceInterface {
  @override
  Future<String> recognizeTextFromPath(String imagePath) async {
    // Artificial small delay to simulate sub-100ms on-device scanning feel
    await Future.delayed(const Duration(milliseconds: 90));

    // If path matches a sample or default fallback
    return SampleReceiptsData.samples[0].rawOcrText;
  }

  @override
  void dispose() {}
}

OcrServiceInterface getOcrService() => OcrServiceWeb();
