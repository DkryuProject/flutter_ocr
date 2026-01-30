import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';

class CardScanController extends GetxController {
  final cardNumber = ''.obs;
  final expiryDate = ''.obs;
  final isProcessing = false.obs;

  final textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> scanCard(XFile image) async {
    isProcessing.value = true;

    final inputImage = InputImage.fromFilePath(image.path);
    final result = await textRecognizer.processImage(inputImage);

    for (final block in result.blocks) {
      for (final line in block.lines) {
        _parseText(line.text);
      }
    }

    isProcessing.value = false;
  }

  void _parseText(String text) {
    final cardRegex =
    RegExp(r'\b(\d{4}[\s-]?){3}\d{4}\b');
    final expiryRegex =
    RegExp(r'(0[1-9]|1[0-2])\/?([0-9]{2})');

    if (cardRegex.hasMatch(text)) {
      cardNumber.value =
          cardRegex.firstMatch(text)!.group(0)!
              .replaceAll(RegExp(r'\s|-'), '');
    }

    if (expiryRegex.hasMatch(text)) {
      expiryDate.value = expiryRegex.firstMatch(text)!.group(0)!;
    }
  }

  @override
  void onClose() {
    textRecognizer.close();
    super.onClose();
  }
}
