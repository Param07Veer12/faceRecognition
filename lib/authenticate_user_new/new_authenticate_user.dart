// import 'dart:async';
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// class FaceBlinkCapturePage extends StatefulWidget {
//   const FaceBlinkCapturePage({Key? key}) : super(key: key);

//   @override
//   State<FaceBlinkCapturePage> createState() => _FaceBlinkCapturePageState();
// }

// class _FaceBlinkCapturePageState extends State<FaceBlinkCapturePage> {
//   late CameraController _cameraController;
//   late FaceDetector _faceDetector;
//   bool _isDetecting = false;
//   bool _imageCaptured = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         enableClassification: true,
//         performanceMode: FaceDetectorMode.fast,
//       ),
//     );
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCam = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);

//     _cameraController = CameraController(frontCam, ResolutionPreset.medium);
//     await _cameraController.initialize();
//     _cameraController.startImageStream(_processCameraImage);

//     if (mounted) setState(() {});
//   }

//   void _processCameraImage(CameraImage image) async {
//     if (_isDetecting || _imageCaptured) return;
//     _isDetecting = true;

//     final WriteBuffer allBytes = WriteBuffer();
//     for (final Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }

//     final bytes = allBytes.done().buffer.asUint8List();
//     final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

//     final camera = _cameraController.description;
//     final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

//     final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

//     final planeData = image.planes.map(
//       (Plane plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       },
//     ).toList();

//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat,
//       planeData: planeData,
//     );

//     final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

//     try {
//       final faces = await _faceDetector.processImage(inputImage);
//       if (faces.isNotEmpty) {
//         final face = faces.first;

//         final leftEye = face.leftEyeOpenProbability ?? 1.0;
//         final rightEye = face.rightEyeOpenProbability ?? 1.0;

//         if (leftEye < 0.3 && rightEye < 0.3) {
//           // Blink Detected
//           _captureImage();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error detecting face: $e');
//     } finally {
//       _isDetecting = false;
//     }
//   }

//   Future<void> _captureImage() async {
//     try {
//       _imageCaptured = true;
//       await _cameraController.stopImageStream();
//       await _cameraController.setFlashMode(FlashMode.off);

//       final file = await _cameraController.takePicture();

//       if (!mounted) return;

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PreviewImagePage(imagePath: file.path),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error capturing image: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraController.value.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Blink to Capture')),
//       body: CameraPreview(_cameraController),
//     );
//   }
// }

// class PreviewImagePage extends StatelessWidget {
//   final String imagePath;
//   const PreviewImagePage({Key? key, required this.imagePath}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Captured Image")),
//       body: Center(
//         child: Image.file(File(imagePath)),
//       ),
//     );
//   }
// }
