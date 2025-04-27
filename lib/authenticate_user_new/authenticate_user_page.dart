import 'dart:convert';
import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:new_face_ai_project/authenticate_user/user_authenticated_page.dart';
import 'package:new_face_ai_project/constants/database_helper.dart';
import 'package:new_face_ai_project/models.dart';

class AuthenticateNewUserPage extends StatefulWidget {
  const AuthenticateNewUserPage({super.key});

  @override
  State<AuthenticateNewUserPage> createState() => _AuthenticateNewUserPageState();
}

class _AuthenticateNewUserPageState extends State<AuthenticateNewUserPage> {
  Uint8List? _capturedImageBytes;
  bool isIdentifying = false;
  var faceSdk = FaceSDK.instance;
  String similarity = "";
  MatchFacesImage? mfImage1;
  MatchFacesImage? mfImage2;
  late FaceCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = FaceCameraController(
      autoCapture: true,
      ignoreFacePositioning: false,
      performanceMode: FaceDetectorMode.fast,
      defaultCameraLens: CameraLens.front,
      onCapture: _processCapturedImage,
      onFaceDetected: (Face? face) {},
    );
  }

  Future<void> _processCapturedImage(File? image) async {
    if (image == null) return;

    setState(() => isIdentifying = true);
    
    try {
      final imageBytes = await image.readAsBytes();
      mfImage1 = MatchFacesImage(imageBytes, ImageType.PRINTED);
      
      final dbHelper = DatabaseHelper();
      final users = await dbHelper.getAllUsers();

      if (users.isEmpty) {
        _showErrorDialog('No users registered');
        return;
      }

      bool matchFound = false;
      for (final user in users) {
        try {
          mfImage2 = MatchFacesImage(base64Decode(user.image), ImageType.PRINTED);
          final request = MatchFacesRequest([mfImage1!, mfImage2!]);
          final response = await faceSdk.matchFaces(request);
          final split = await faceSdk.splitComparedFaces(response.results, 0.75);

          similarity = split!.matchedFaces.isNotEmpty
              ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
              : "error";

          if (similarity != 'error' && double.parse(similarity) > 90.00) {
            matchFound = true;
            _showSuccessDialog(user.name);
            break;
          }
        } catch (e) {
          debugPrint('Error comparing faces: $e');
        }
      }

      if (!matchFound) {
        _showErrorDialog('No matching user found');
      }
    } catch (e) {
      _showErrorDialog('Error during identification: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isIdentifying = false);
    }
  }

  Future<void> _resetCamera() async {
    try {
      await controller.startImageStream();
    } catch (e) {
      debugPrint('Error resetting camera: $e');
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Identification Successful'),
        content: Text('Welcome back, $name!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            _resetCamera() ;
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Identification Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetCamera();
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
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
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
      body: Stack(
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
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}