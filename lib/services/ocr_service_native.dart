import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service_interface.dart';

class OcrServiceNative implements OcrServiceInterface {
  TextRecognizer? _textRecognizer;

  TextRecognizer get recognizer =>
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeTextFromPath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      // Return error message or fallback
      return 'Lỗi nhận diện văn bản ML Kit: $e';
    }
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}

OcrServiceInterface getOcrService() => OcrServiceNative();
