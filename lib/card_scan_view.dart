import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import 'main.dart';
import 'card_scan_controller.dart';

class CardScanView extends StatefulWidget {
  @override
  State<CardScanView> createState() => _CardScanViewState();
}

class _CardScanViewState extends State<CardScanView> {
  late CameraController cameraController;
  final controller = Get.put(CardScanController());

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
      ),
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카드 OCR 스캔')),
      body: FutureBuilder(
        future: cameraController.initialize(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              ),

              const SizedBox(height: 12),

              Obx(() => controller.isProcessing.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  final image =
                  await cameraController.takePicture();
                  await controller.scanCard(image);
                },
                child: const Text('카드 촬영'),
              )),

              const Divider(),

              Obx(() => Text(
                '카드번호: ${controller.cardNumber.value}',
                style: const TextStyle(fontSize: 16),
              )),

              Obx(() => Text(
                '만료일: ${controller.expiryDate.value}',
                style: const TextStyle(fontSize: 16),
              )),

              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '※ 카드 정보는 저장되지 않으며\n자동 입력을 돕기 위한 기능입니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
