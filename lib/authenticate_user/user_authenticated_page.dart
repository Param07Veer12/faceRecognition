import 'package:flutter/material.dart';
import 'package:new_face_ai_project/constants/colors.dart';

class UserAuthenticatedPage extends StatelessWidget {
  final String name;

  const UserAuthenticatedPage({
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Authenticated!!!'),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: primaryWhite,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: primaryWhite,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Hey, ${name.toUpperCase()}!',
              style: TextStyle(
                color: primaryWhite,
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            ),
            Text(
              'You are Successfully Authenticated!',
              style: TextStyle(
                color: primaryWhite.withOpacity(0.6),
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
