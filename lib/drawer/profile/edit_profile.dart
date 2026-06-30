import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/update_data.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/custom_dialog.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/widgets/cached_app_image.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel updateData = UserModel();
  var genderList = ['Male', 'Female', 'Others'];
  late String selectedGender = genderList.first;
  bool isGenderChanged = false;
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
  XFile? imageFile;

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
      setState(() => birthdateController.text = dateFormat.format(picked));
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted) return;
    Navigator.pop(context);
    if (pickedFile == null) return;

    setState(() {
      imageFile = pickedFile;
      isImagePicked = true;
    });
    await uploadPicture();
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (!mounted) return;
    Navigator.pop(context);
    if (pickedFile == null) return;

    setState(() {
      imageFile = pickedFile;
      isImagePicked = true;
    });
    await uploadPicture();
  }

  Future uploadPicture() async {
    showLoadingAlertDialog(context, 'Uploading Profile Picture');
    try {
      if (imageFile == null) {
        throw Exception('No image selected.');
      }
      var file = File(imageFile!.path);
      Reference firebaseStorage =
          FirebaseStorage.instance.ref().child("images/${user!.uid}");

      final uploadTask = await firebaseStorage.putFile(file);
      updateData.photoURL = await uploadTask.ref.getDownloadURL();
      await updateProfilePicToFirestore(updateData.photoURL);

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to upload profile picture: $error')),
        );
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
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
            context.go(AppRoutes.dashboard);
          },
          icon: const Icon(Icons.arrow_back_ios),
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
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 10)),
                                ],
                                shape: BoxShape.circle,
                              ),
                              child: CachedCircleImage(
                                imageUrl: updateData.photoURL == '' ||
                                        updateData.photoURL == null
                                    ? defaultProfileUrl
                                    : updateData.photoURL.toString(),
                                size: 130,
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
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 4,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest)),
                          child: IconButton(
                            onPressed: () async {
                              _showChoiceDialog(context);
                            },
                            padding: const EdgeInsets.only(right: 2),
                            icon: const Icon(
                              Icons.add_a_photo,
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
              buildTextField("Phone Number", updateData.mobile ?? "",
                  Icons.mobile_screen_share, phoneController, false),
              buildTextField("Email ", updateData.email ?? "", Icons.mail,
                  emailController, true),

              //Birth Date Picker
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  controller: birthdateController,
                  decoration: InputDecoration(
                    labelText: 'DOB',
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).iconTheme.color,
                      size: 32,
                    ),
                    suffixIcon: Icon(Icons.edit,
                        color: Theme.of(context).appBarTheme.foregroundColor),
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
                    return null;
                  },
                ),
              ),
              //Gender
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.group_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: 32,
                      ),
                      labelText: 'Gender',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  value: genderList.contains(updateData.gender)
                      ? updateData.gender
                      : selectedGender,
                  icon: Icon(Icons.arrow_drop_down,
                      color: Theme.of(context).appBarTheme.foregroundColor),
                  iconSize: 26,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                      isGenderChanged = !isGenderChanged;
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

              buildTextField("height", updateData.height ?? "height",
                  Icons.height, heightController, false),
              buildTextField("weight", updateData.weight ?? "weight",
                  Icons.ac_unit, weightController, false),
              buildTextField("Location", updateData.location ?? "Location",
                  Icons.location_city, locationController, false),
              buildTextField("About", updateData.bio ?? "Short Description",
                  Icons.info_sharp, bioController, false),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveProfile,
                      child: const Text("Save"),
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

  Future<void> _saveProfile() async {
    final photoURL = (updateData.photoURL?.isNotEmpty ?? false)
        ? updateData.photoURL
        : defaultProfileUrl;
    final gender = isGenderChanged
        ? selectedGender
        : (updateData.gender?.isNotEmpty == true
            ? updateData.gender
            : selectedGender);

    await updateDetailsToFirestore(
      photoURL,
      _editedOrExisting(usernameController, updateData.username),
      _editedOrExisting(nameController, updateData.name),
      _editedOrExisting(phoneController, updateData.mobile),
      _editedOrExisting(locationController, updateData.location),
      _editedOrExisting(birthdateController, updateData.birthdate),
      _editedOrExisting(bioController, updateData.bio),
      _editedOrExisting(heightController, updateData.height),
      _editedOrExisting(weightController, updateData.weight),
      gender,
      updateData.bmi,
      updateData.bmr,
      context,
    );
  }

  String? _editedOrExisting(
      TextEditingController controller, String? existing) {
    final edited = controller.text.trim();
    return edited.isEmpty ? existing : edited;
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
          return null;
        },
        controller: text,
        onSaved: (value) {
          text.text = value!;
        },
        readOnly: isEmail,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
            size: 32,
          ),
          suffixIcon: isEmail
              ? Icon(
                  Icons.lock,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                )
              : Icon(
                  Icons.edit,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: lableText,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeHolder,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
