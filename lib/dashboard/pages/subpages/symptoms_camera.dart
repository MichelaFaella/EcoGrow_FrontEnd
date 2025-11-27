import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utility/app_colors.dart';
import '../service/plant_service.dart';
import 'disease_ifo.dart';

class SymptomCameraPage extends StatefulWidget {
  final List<String> symptoms;
  final String familyId;
  final String plantId;   // 🔥 SOLO plantId (user_id viene letto dal JWT)

  const SymptomCameraPage({
    super.key,
    required this.symptoms,
    required this.familyId,
    required this.plantId,
  });

  @override
  State<SymptomCameraPage> createState() => _SymptomCameraPageState();
}

class _SymptomCameraPageState extends State<SymptomCameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isUploading = false;

  final plantService = PlantService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // -----------------------------------------------------------
  // INIT CAMERA
  // -----------------------------------------------------------
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
      debugPrint("[SymptomCamera] ERROR init camera: $e");
    }
  }

  // -----------------------------------------------------------
  // TAKE PICTURE
  // -----------------------------------------------------------
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

    } catch (e) {
      debugPrint("[SymptomCamera] ERROR takePicture: $e");
    }
  }

  // -----------------------------------------------------------
  // CONFIRM → SEND TO API
  // -----------------------------------------------------------
  Future<void> _confirmAndSend() async {
    if (_capturedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final original = File(_capturedImage!.path);

      // ---- compress JPEG ----
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        original.path,
        quality: 40,
        format: CompressFormat.jpeg,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (compressedBytes == null) {
        _showError("Compression failed");
        return;
      }

      final cmpPath = original.path.replaceAll(".jpg", "_cmp.jpg");
      final compressedFile = File(cmpPath);
      await compressedFile.writeAsBytes(compressedBytes);

      // =====================================================
      // CALL API (only: plant_id + family_id + symptoms)
      // user_id viene preso automaticamente dal JWT
      // =====================================================
      final (ok, msg, data) = await plantService.diseaseDetection(
        imageFile: compressedFile,
        familyId: widget.familyId,
        symptoms: widget.symptoms,
        plantId: widget.plantId,
      );

      if (!ok) {
        _showError(msg ?? "Unknown error");
        return;
      }

      // APRI DETTAGLI MALATTIA
      final diagnosisResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiseaseInfoPage(data: data ?? {}),
        ),
      );

      // Ritorna alla DiseasePage
      Navigator.pop(context, diagnosisResult);

    } catch (e) {
      _showError("Upload error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // -----------------------------------------------------------
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImage == null
          ? _buildCameraView()
          : _buildPreviewView(),
    );
  }

  // -----------------------------------------------------------
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
                      width: 320,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "Take a photo of the part showing symptoms",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 12,
                          fontFamily: "Poppins",
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

  // -----------------------------------------------------------
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
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _confirmAndSend,
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
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
