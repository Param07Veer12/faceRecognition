import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:new_face_ai_project/authenticate_user/authenticate_user_page.dart';
import 'package:new_face_ai_project/authenticate_user_new/authenticate_user_page.dart';
import 'package:new_face_ai_project/constants/colors.dart';
import 'package:new_face_ai_project/constants/custom_button.dart';
import 'package:new_face_ai_project/face_authentication.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

  await FaceCamera.initialize();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldClr,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Face Authentication',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  color: textColor,
                ),
              ),
              SizedBox(height: 40),
              CustomButton(
                label: 'Register User',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RegisterUserPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              CustomButton(
                label: 'Authenticate User',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AuthenticateNewUserPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
