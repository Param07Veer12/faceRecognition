import 'dart:convert';

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

class AuthenticateUserPage extends StatefulWidget {
  const AuthenticateUserPage({super.key});

  @override
  State<AuthenticateUserPage> createState() => _AuthenticateUserPageState();
}

class _AuthenticateUserPageState extends State<AuthenticateUserPage> {
   
  Uint8List? _capturedImageBytes;

  bool canAuthenticate = false;
  bool faceMatched = false;
  bool isMatching = false;
  var faceSdk = FaceSDK.instance;

  String similarity = "";
  MatchFacesImage? mfImage1;
  MatchFacesImage? mfImage2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authenticate User'),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: primaryGrey,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  CaptureFaceView(
                    onImageCaptured: (imageBytes) {
                      _capturedImageBytes = imageBytes;
mfImage1 = MatchFacesImage(imageBytes, ImageType.PRINTED);
                      setState(() {
                        canAuthenticate = true;
                      });
                    },
                  ),
                  if (isMatching)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 52),
                        child: AnimatedView(),
                      ),
                    ),
                ],
              ),
              Spacer(),
              if (canAuthenticate)
                CustomButton(
                  label: 'Authenticate',
                  onTap: () async {
                     if (_capturedImageBytes == null) return;
    
    setState(() => isMatching = true);

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

    setState(() => isMatching = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
