import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utility/app_colors.dart';

class SymptomCameraPage extends StatefulWidget {
  final List<String> symptoms;

  const SymptomCameraPage({super.key, required this.symptoms});

  @override
  State<SymptomCameraPage> createState() => _SymptomCameraPageState();
}

class _SymptomCameraPageState extends State<SymptomCameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

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
      debugPrint("[SymptomCameraPage] ERROR init camera: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _initializeControllerFuture;
      final raw = await _controller!.takePicture();

      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final saved = await File(raw.path).copy(path);

      setState(() => _capturedImage = XFile(saved.path));

      await _controller?.dispose();
      _controller = null;

    } catch (e) {
      debugPrint("[SymptomCameraPage] ERROR takePicture: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // -----------------------------------------------------
  // UI
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

              // ------------ MESSAGGIO ----------------
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
                        "Take a photo of the part of the plant where you noticed these changes",
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

              // ------------ BOTTONE FOTO --------------
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

  Widget _buildPreviewView() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
        ),

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
                    style: TextStyle(color: AppColors.white),
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
                  onPressed: () {
                    Navigator.pop(context, _capturedImage);
                  },
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
