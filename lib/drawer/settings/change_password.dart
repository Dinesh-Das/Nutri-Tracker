import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  void _changePassword(String currentPassword, String newPassword) async {
    final user = await FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);

    user.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword).then((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (contex) => const LoginScreen()));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error Occured :${error.toString()}'),
        ));
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool isOldPass = true;
  bool isNewPass = true;
  bool isCnewpass = true;
  final oldPassword = TextEditingController();
  final newPass = TextEditingController();
  final confirmNewPass = TextEditingController();
  String? userEmail = FirebaseAuth.instance.currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/forgot_password.png",
                    colorBlendMode: BlendMode.overlay,
                  ),
                  //Email
                  TextFormField(
                    autofocus: false,
                    initialValue: userEmail.toString(),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //Old pass
                  TextFormField(
                    autofocus: false,
                    obscureText: isOldPass,
                    controller: oldPassword,
                    validator: (value) {
                      RegExp regex = RegExp(
                          r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$).{8,20}$");
                      if (value!.isEmpty) {
                        return ("Password is required!");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("Enter Valid Password(Min.8 Character)");
                      }
                    },
                    onSaved: (value) {
                      oldPassword.text = value!;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key),
                        suffixIcon: InkWell(
                          child: isOldPass
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onTap: () {
                            setState(() {
                              isOldPass = !isOldPass;
                            });
                          },
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: "Enter Current Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  //new pass
                  TextFormField(
                    autofocus: false,
                    obscureText: isNewPass,
                    controller: newPass,
                    validator: (value) {
                      RegExp regex = RegExp(
                          r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$).{8,20}$");

                      if (value!.isEmpty) {
                        return ("Password is required!");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("Enter Valid Password(Min.8 Character)");
                      }
                    },
                    onSaved: (value) {
                      newPass.text = value!;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key),
                        suffixIcon: InkWell(
                          child: isNewPass
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onTap: () {
                            setState(() {
                              isNewPass = !isNewPass;
                            });
                          },
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: "Enter New Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //confirm new
                  TextFormField(
                    autofocus: false,
                    obscureText: isCnewpass,
                    controller: confirmNewPass,
                    validator: (value) {
                      RegExp regex = RegExp(
                          r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$).{8,20}$");

                      if (value!.isEmpty) {
                        return ("Password is required!");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("Enter Valid Password(Min.8 Character)");
                      }
                    },
                    onSaved: (value) {
                      confirmNewPass.text = value!;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key),
                        suffixIcon: InkWell(
                          child: isCnewpass
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onTap: () {
                            setState(() {
                              isCnewpass = !isCnewpass;
                            });
                          },
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: "Confirm New Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Material(
                    color: Colors.green,
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    child: MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _changePassword(oldPassword.text, newPass.text);
                        }
                      },
                      child: const Text(
                        'Change Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
