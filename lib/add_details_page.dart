
import 'package:flutter/material.dart';
import 'package:new_face_ai_project/constants/custom_button.dart';
import 'package:new_face_ai_project/constants/custom_text_form_field.dart';
import 'package:new_face_ai_project/constants/database_helper.dart';
import 'package:new_face_ai_project/models.dart';
import 'package:new_face_ai_project/snack_bars.dart';
import 'package:uuid/uuid.dart';

class AddDetailsPage extends StatefulWidget {
  final String image;
  const AddDetailsPage({
    required this.image,
    super.key,
  });

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  final nameController = TextEditingController();
  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Details"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextFormField(
                formFieldKey: formFieldKey,
                controller: nameController,
                hintText: 'Name',
                validate: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter a name';
                  }

                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomButton(
                label: 'Register Now',
                onTap: () async {
                  if (formFieldKey.currentState!.validate()) {
               FocusScope.of(context).unfocus();

final name = nameController.text;
final userId = Uuid().v4();

final newUser = User(
  id: userId,
  name: name,
  image: widget.image,
);

showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Center(
    child: CircularProgressIndicator(),
  ),
);

try {
  final dbHelper = DatabaseHelper();
  await dbHelper.insertUser(newUser);
  
  Navigator.of(context).pop();
  successSnackBar(context, 'Registration success!');

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context)
      ..pop()
      ..pop();
  });
} catch (e) {
  Navigator.of(context).pop();
  errorSnackBar(context, 'Registration Failed!');
}
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
