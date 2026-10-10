abstract class OcrServiceInterface {
  Future<String> recognizeTextFromPath(String imagePath);
  void dispose();
}
