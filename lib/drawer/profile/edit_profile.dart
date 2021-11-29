import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  var genderList = ['Male', 'Female', 'Others'];
  late String selectedGender = genderList.first;
  bool isImagePicked = false;
  //Editing Controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  PickedFile? imageFile;

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
    // Open gallery code
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      imageFile = pickedFile;
      isImagePicked = true;
    });
    uploadPicture();
    Navigator.pop(context);
  }

  void _openCamera(BuildContext context) async {
    //Camera code
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = pickedFile;
      isImagePicked = true;
    });
    uploadPicture();
    Navigator.pop(context);
  }

  uploadPicture() async {
    if (imageFile != null) {
      // File filename = File(imageFile!.path);
      var file = File(imageFile!.path);
      Reference firebaseStorage = await FirebaseStorage.instance
          .ref()
          .child("images/${updateData.uid}");

      UploadTask uploadTask = firebaseStorage.putFile(file);
      uploadTask.whenComplete(() async {
        updateData.photoURL = await firebaseStorage.getDownloadURL();
        print(updateData.photoURL);
      });
      // uploadTask.then((res) {
      //   res.ref.getDownloadURL();
      //   print(res.ref.getDownloadURL());
      // });
    } else {
      const ScaffoldMessenger(
        child: SnackBar(content: Text('No Image Path Received')),
      );
    }
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
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(80.0),
                            //   child: (imageFile == null)
                            //       ? Image.network(
                            //           defaultProfileUrl,
                            //           fit: BoxFit.cover,
                            //           width: 120,
                            //           height: 120,
                            //         )
                            //       : Image.file(
                            //           File(imageFile!.path),
                            //           fit: BoxFit.cover,
                            //           width: 120,
                            //           height: 120,
                            //         ),
                            // ),
                            Container(
                              width: 120,
                              height: 120,
                              child: CircleAvatar(
                                backgroundImage: updateData.photoURL == ''
                                    ? NetworkImage(defaultProfileUrl)
                                    : NetworkImage(
                                        updateData.photoURL.toString()),
                              ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 4, color: Colors.grey),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 10)),
                                ],
                                shape: BoxShape.circle,
                              ),
                            )
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
                              border: Border.all(width: 4, color: Colors.grey)),
                          child: IconButton(
                            onPressed: () async {
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
                padding: const EdgeInsets.only(bottom: 25),
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
              //Gender
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.group_outlined),
                    labelText: 'Gender',
                  ),
                  value: updateData.gender == ''
                      ? selectedGender
                      : updateData.gender,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 26,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  isExpanded: false,
                  items:
                      genderList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

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
                      // uploadPicture();
                      updateDetailsToFirestore(
                          isImagePicked && updateData.photoURL != ''
                              ? updateData.photoURL
                              : defaultProfileUrl,
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
                          (selectedGender == updateData.gender)
                              ? updateData.gender
                              : selectedGender,
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
