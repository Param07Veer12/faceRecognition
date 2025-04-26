import 'dart:convert';
import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:new_face_ai_project/authenticate_user/scanning_animation/animated_view.dart';
import 'package:new_face_ai_project/authenticate_user/user_authenticated_page.dart';
import 'package:new_face_ai_project/capture_face_view.dart' show CaptureFaceView;
import 'package:new_face_ai_project/constants/colors.dart';
import 'package:new_face_ai_project/constants/custom_button.dart';
import 'package:new_face_ai_project/constants/database_helper.dart';
import 'package:new_face_ai_project/models.dart';
import 'package:new_face_ai_project/snack_bars.dart' show errorSnackBar;

class AuthenticateNewUserPage extends StatefulWidget {
  const AuthenticateNewUserPage({super.key});

  @override
  State<AuthenticateNewUserPage> createState() => _AuthenticateNewUserPageState();
}

class _AuthenticateNewUserPageState extends State<AuthenticateNewUserPage> {
   
  Uint8List? _capturedImageBytes;

  bool canAuthenticate = false;
  bool faceMatched = false;
  bool isMatching = false;
  var faceSdk = FaceSDK.instance;

  String similarity = "";
  MatchFacesImage? mfImage1;
  MatchFacesImage? mfImage2;
  File? _capturedImage;
Future<Uint8List?> convertFileToUint8List(File? file) async {
  if (file == null) return null;
  try {
    return await file.readAsBytes();
  } catch (e) {
    print("Error converting file to Uint8List: $e");
    return null;
  }
}
  late FaceCameraController controller;

  @override
  void initState() {
      controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) async {


        setState(() => _capturedImage = image);
Uint8List? imageBytes = await convertFileToUint8List(_capturedImage);

        mfImage1 = MatchFacesImage(imageBytes!, ImageType.PRINTED);

    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAllUsers();

    if (users.isEmpty) {
      errorSnackBar(context, 'No users registered');
      setState(() => isMatching = false);
      return;
    }

    bool matchFound = false;

    for (final user in users) {
      try {
      
mfImage2 = MatchFacesImage(base64Decode(user.image), ImageType.PRINTED);

    var request = MatchFacesRequest([mfImage1!, mfImage2!]);
    var response = await faceSdk.matchFaces(request);
    var split = await faceSdk.splitComparedFaces(response.results, 0.75);

                          similarity = split!.matchedFaces.length > 0
                              ? (split.matchedFaces[0]!.similarity! * 100)
                                  .toStringAsFixed(2)
                              : "error";

     
                          if (similarity != 'error' &&
                              double.parse(similarity) > 90.00) {
          matchFound = true;
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => UserAuthenticatedPage(name: user.name),
          ));
          break;
        }
      } catch (e) {
        print('Error comparing faces: $e');
      }
    }

    if (!matchFound) {
      errorSnackBar(context, 'No matching user found');
    }

      },
      onFaceDetected: (Face? face) {
        //Do something
      },
    );
      // _initializeCamera();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Authenticate'),
            
          ),
          body: Builder(builder: (context) {
            if (_capturedImage != null) {
              return Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.file(
                      _capturedImage!,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await controller.startImageStream();
                          setState(() => _capturedImage = null);
                        },
                        child: const Text(
                          'Capture Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ))
                  ],
                ),
              );
            }
            return SmartFaceCamera(
                controller: controller,
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the square');
                  }
                  return const SizedBox.shrink();
                });
          })),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
