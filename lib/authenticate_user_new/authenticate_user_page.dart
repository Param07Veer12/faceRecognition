import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:new_face_ai_project/constants/database_helper.dart';
import 'package:new_face_ai_project/models.dart';

class AuthenticateNewUserPageFace extends StatefulWidget {
  const AuthenticateNewUserPageFace({super.key});

  @override
  State<AuthenticateNewUserPageFace> createState() => _AuthenticateNewUserPageFaceState();
}

class _AuthenticateNewUserPageFaceState extends State<AuthenticateNewUserPageFace> {
  late FaceCameraController controller;
  late List<User> users;
  bool hasCaptured = false;
  bool isIdentifying = false;
  String similarity = "";
  final faceSdk = FaceSDK.instance;

  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeAndSetup();
  }

  Future<void> _initializeAndSetup() async {
    // Ask for camera & microphone permissions
  

    // Load users from DB
    final dbHelper = DatabaseHelper();
    users = await dbHelper.getAllUsers();

    // Initialize camera controller
    controller = FaceCameraController(
      autoCapture: false,
      ignoreFacePositioning: false,
      performanceMode: FaceDetectorMode.accurate,
      defaultCameraLens: CameraLens.front,
      onCapture: _processCapturedImage,
      onFaceDetected: (Face? face) {
        if (face != null && !hasCaptured) {
          setState(() => hasCaptured = true);
          controller.captureImage();
        }
      },
    );
  }

  Future<void> _processCapturedImage(File? imageFile) async {
    if (imageFile == null) return;

    setState(() => isIdentifying = true);

    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      final resized = img.copyResize(decodedImage!, width: 480);
      final resizedBytes = img.encodeJpg(resized, quality: 85);

      final mfImage1 = MatchFacesImage(Uint8List.fromList(imageBytes), ImageType.PRINTED);

      if (users.isEmpty) {
        _showErrorDialog('No users registered');
        return;
      }

      bool matchFound = false;

      for (final user in users) {
        try {
          final mfImage2 = MatchFacesImage(base64Decode(user.image), ImageType.PRINTED);
          final request = MatchFacesRequest([mfImage1, mfImage2]);
          final response = await faceSdk.matchFaces(request);
          final split = await faceSdk.splitComparedFaces(response.results, 0.75);

          similarity = split!.matchedFaces.isNotEmpty
              ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
              : "error";

          if (similarity != "error" && double.parse(similarity) > 90.0) {
            matchFound = true;
            _showSuccessDialog(user.name);
            break;
          }
        } catch (e) {
          debugPrint('Face match error: $e');
        }
      }

      if (!matchFound) {
        _showErrorDialog('No matching user found');
      }
    } catch (e) {
      _showErrorDialog('Error during identification: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          hasCaptured = false;
          isIdentifying = false;
        });
      }
    }
  }
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String message) async {
    await flutterTts.stop();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(message);
  }

  Future<void> _showToastWithSpeech({
    required String message,
    required bool success,
    required VoidCallback onComplete,
  }) async {
    // Speak message
    await _speak(message);

    // Show toast
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      background: success ? Colors.green[800]! : Colors.red[800]!,
      position: NotificationPosition.bottom,
      duration: const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.down,
    );

    // Wait for toast duration
    await Future.delayed(const Duration(seconds: 3));

    // Reset camera
    onComplete();
  }
  Future<void> _resetCamera() async {
    try {
      await controller.startImageStream();
    } catch (e) {
      debugPrint('Camera reset error: $e');
    }
  }

   void _showSuccessDialog(String name) {
    final message = "Identification successful. Welcome $name!";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Identification Successful'),
        content: Text('Welcome back, $name!'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _showToastWithSpeech(
                message: message,
                success: true,
                onComplete: _resetCamera,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final spokenMessage = "Identification failed. $message.";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Identification Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _showToastWithSpeech(
                message: spokenMessage,
                success: false,
                onComplete: _resetCamera,
              );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }


  Widget _buildMessage(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SmartFaceCamera(
                controller: controller,
                autoDisableCaptureControl: true,
                messageBuilder: (context, face) {
                  if (face == null) return _buildMessage('Place your face in the camera');
                  if (!face.wellPositioned) return _buildMessage('Center your face in the square');
                  return const SizedBox.shrink();
                },
              ),
              if (isIdentifying)
                Stack(
                  children: [
                    ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Identifying... Please wait',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
