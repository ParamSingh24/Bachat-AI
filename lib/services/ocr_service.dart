import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'receipt_parser.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // Use latin as it supports English & some Hindi transliterations if applicable. Otherwise we'd need multiple recognizers.

  Future<Map<String, dynamic>?> scanReceipt(String geminiKey) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null; // User cancelled

    final inputImage = InputImage.fromFile(File(image.path));
    
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return await ReceiptParser.parseWithAI(recognizedText.text, geminiKey);
    } catch (e) {
      print("OCR Error: $e");
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
