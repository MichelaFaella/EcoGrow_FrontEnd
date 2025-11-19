import 'dart:io';
import 'package:Ecogrow/dashboard/pages/service/plant_service.dart';
import 'package:Ecogrow/utility/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'garden.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // -----------------------------------------------------
  // INIT CAMERA
  // -----------------------------------------------------
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("[CameraPage] ERROR init camera: $e");
    }
  }

  // -----------------------------------------------------
  // TAKE PICTURE
  // -----------------------------------------------------
  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      await _initializeControllerFuture;
      final raw = await _controller!.takePicture();

      final dir = await getTemporaryDirectory();
      final jpgPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final saved = await File(raw.path).copy(jpgPath);

      setState(() => _capturedImage = XFile(saved.path));

      await _controller?.dispose();
      _controller = null;

      debugPrint("[CameraPage] Foto salvata: $jpgPath");

    } catch (e) {
      debugPrint("[CameraPage] ERROR takePicture: $e");
    }
  }

  // -----------------------------------------------------
  // SEND TO API + COMPRESS
  // -----------------------------------------------------
  Future<void> _sendToApi() async {
    if (_capturedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final original = File(_capturedImage!.path);
      debugPrint("[CameraPage] Original size: ${await original.length()} bytes");

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        original.path,
        quality: 40,
        format: CompressFormat.jpeg,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (compressedBytes == null) {
        throw Exception("Compression failed");
      }

      final compressedPath =
      original.path.replaceAll(".jpg", "_cmp.jpg");
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint("[CameraPage] Compressed size: ${compressedBytes.length} bytes");

      final plantService = PlantService();
      final result =
      await plantService.createPlant(imageFile: compressedFile);

      final ok = result.$1;
      final message = result.$2;
      final data = result.$3;

      if (!ok) {
        _showErrorToast(message ?? "Upload error");
        return;
      }

      debugPrint("[CameraPage] Plant created → ID: ${data?["id"]}");

      // SUCCESS TOAST
      showToastCorrect(context, "Plant created successfully!");

      // Delay per far vedere il toast
      await Future.delayed(const Duration(milliseconds: 600));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GardenPage()),
      );

    } catch (e) {
      debugPrint("[CameraPage] ERROR sendToApi: $e");
      _showErrorToast("Errore upload: $e");

    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // -----------------------------------------------------
  // SMALL ERROR TOAST
  // -----------------------------------------------------
  void _showErrorToast(String msg) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  // -----------------------------------------------------
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // -----------------------------------------------------
  // UI BUILD
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImage == null
          ? _buildCameraView()
          : _buildPreviewView(),
    );
  }

  // -----------------------------------------------------
  // CAMERA VIEW
  // -----------------------------------------------------
  Widget _buildCameraView() {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller != null) {
          return Stack(
            children: [
              Positioned.fill(child: CameraPreview(_controller!)),

              Center(
                child: Container(
                  width: 350,
                  height: 650,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.green, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Take a photo of the plant on a uniform background",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontFamily: "Poppins",
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 44,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // -----------------------------------------------------
  // PREVIEW VIEW
  // -----------------------------------------------------
  Widget _buildPreviewView() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
        ),

        if (_isUploading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),

        if (!_isUploading)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // RETAKE
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      setState(() => _capturedImage = null);
                      await _initCamera();
                    },
                    child: const Text(
                      "Retake",
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // CONFIRM
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _sendToApi,
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------
// SUCCESS TOAST (già pronto, uguale al tuo originale)
// ------------------------------------------------------------
void showToastCorrect(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.done,
                  size: 25,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry.remove();
  });
}
