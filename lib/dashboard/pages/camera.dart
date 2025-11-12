import 'dart:io';
import 'package:Ecogrow/utility/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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

  /// Inizializza la fotocamera (solo per scattare foto)
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Errore inizializzazione fotocamera: $e');
    }
  }

  /// Scatta una foto e la salva localmente
  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await File(image.path).copy(imagePath);

      setState(() {
        _capturedImage = XFile(savedImage.path);
      });
    } catch (e) {
      debugPrint('Errore durante lo scatto: $e');
    }
  }

  /// Invia l'immagine all'API (esempio POST multipart)
  Future<void> _sendToApi() async {
    if (_capturedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse("https://tuo-endpoint-api.com/upload"); // <--- cambia con il tuo URL

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _capturedImage!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImage == null ? _buildCameraView() : _buildPreviewView(),
    );
  }

  /// Vista fotocamera (prima dello scatto)
  Widget _buildCameraView() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              // Anteprima fotocamera centrata e scalata per riempire lo schermo
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),


              // Rettangolo guida
              Center(
                child: Container(
                  width: 350,
                  height: 650,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.green,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                  ),
                ),
              ),

              // Messaggio sopra il rettangolo
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
                        "Take a photo of the plant on a background as uniform as possible",
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

              // Pulsante di scatto centrato in basso
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Sfondo semi-trasparente
                        border: Border.all(color: AppColors.white, width: 5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 44,
                          color: AppColors.green, // Icona trasparente
                        ),
                      ),
                    ),
                  ),
                ),
              ),


              // Miniatura foto (se presente)
              if (_capturedImage != null)
                Positioned(
                  bottom: 30,
                  left: 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_capturedImage!.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Errore nella fotocamera:\n${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Vista di anteprima dopo lo scatto
  Widget _buildPreviewView() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            File(_capturedImage!.path),
            fit: BoxFit.cover,
          ),
        ),

        // Loader durante upload
        if (_isUploading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),

        // Pulsanti di conferma e rifai
        if (!_isUploading)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pulsante Retake
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      child: Text(
                        "Retake",
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Pulsante Confirm
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _sendToApi,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
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
