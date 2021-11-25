import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  PickedFile? imageFile;
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openGallery(context);
                    },
                    title: const Text("Gallery"),
                    leading: const Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openCamera(context);
                    },
                    title: const Text("Camera"),
                    leading: const Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      imageFile = pickedFile!;
    });

    Navigator.pop(context);
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = pickedFile!;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          // color: Colors.green,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings),
            // color: Colors.green,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(80.0),
                            child: (imageFile == null)
                                ? Image.network(
                                    defaultProfileUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Image.file(
                                    File(imageFile!.path),
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 120,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            shape: BoxShape.circle,
                            border: Border.all(width: 4, color: Colors.white)),
                        child: IconButton(
                          onPressed: () {
                            _showChoiceDialog(context);
                          },
                          padding: EdgeInsets.only(right: 2),
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              buildTextField("User Name", "UserUnknown"),
              buildTextField("Full Name", "Dinesh Das"),
              buildTextField("Phone Number", "9284425491"),
              buildTextField("Location", "Aurnagabad, Maharashtra"),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.black),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.green,
                    onPressed: () {},
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String lableText, String placeHolder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: lableText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeHolder,
            hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }
}
