import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/update_data.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel updateData = UserModel();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      updateData = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  //Editing Controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
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

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {birthdateController.text = dateFormat.format(picked)});
    }
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
        padding: const EdgeInsets.only(left: 16, right: 16),
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
                child: SingleChildScrollView(
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
                              border:
                                  Border.all(width: 4, color: Colors.white)),
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
              ),
              const SizedBox(
                height: 25,
              ),
              buildTextField("User Name", updateData.username ?? "UserUnknown",
                  Icons.account_circle_outlined, usernameController, false),
              buildTextField(
                  "Full Name",
                  updateData.name ?? "Full Name",
                  Icons.face_retouching_natural_outlined,
                  nameController,
                  false),
              buildTextField("Phone Number", updateData.mobile ?? "1234567890",
                  Icons.mobile_screen_share, phoneController, false),
              buildTextField("Email ", updateData.email ?? "email@gmail.com",
                  Icons.mail, emailController, true),

              //Birth Date Picker
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  controller: birthdateController,
                  decoration: InputDecoration(
                    labelText: 'DOB',
                    hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.edit),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: updateData.birthdate ?? 'DOB',
                  ),
                  onSaved: (value) {
                    birthdateController.text = value!;
                  },
                  onTap: () {
                    _selectDate();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  maxLines: 1,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Choose Date';
                    }
                  },
                ),
              ),

              buildTextField("Gender", updateData.gender ?? "Male",
                  Icons.group_outlined, genderController, false),
              buildTextField("height", updateData.height ?? "182cm",
                  Icons.height, heightController, false),
              buildTextField("weight", updateData.weight ?? "73", Icons.ac_unit,
                  weightController, false),
              buildTextField(
                  "Location",
                  updateData.location ?? "Aurnagabad, Maharashtra",
                  Icons.location_city,
                  locationController,
                  false),
              buildTextField("About", updateData.bio ?? "Short Description",
                  Icons.info_sharp, bioController, false),
              const SizedBox(
                height: 10,
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
                    onPressed: () {
                      updateDetailsToFirestore(
                          (usernameController.text == '')
                              ? updateData.username
                              : usernameController.text,
                          (nameController.text == '')
                              ? updateData.name
                              : nameController.text,
                          (phoneController.text == '')
                              ? updateData.mobile
                              : phoneController.text,
                          (locationController.text == '')
                              ? updateData.location
                              : locationController.text,
                          (birthdateController.text == '')
                              ? updateData.birthdate
                              : birthdateController.text,
                          (bioController.text == '')
                              ? updateData.bio
                              : bioController.text,
                          (heightController.text == '')
                              ? updateData.height
                              : heightController.text,
                          (weightController.text == '')
                              ? updateData.weight
                              : weightController.text,
                          (genderController.text == '')
                              ? updateData.gender
                              : genderController.text,
                          context);
                    },
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
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String lableText, String placeHolder, IconData icon,
      TextEditingController text, bool isEmail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'Empty';
          }
        },
        controller: text,
        onSaved: (value) {
          text.text = value!;
        },
        readOnly: isEmail,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: isEmail ? Icon(Icons.lock) : Icon(Icons.edit),
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: lableText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeHolder,
          hintStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
