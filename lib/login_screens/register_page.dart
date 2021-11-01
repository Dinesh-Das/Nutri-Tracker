import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nutri_tracker/login_screens/auth.config.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/navigation.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late EmailAuth emailAuth;
  bool isHiddenPassword = true;
  bool isHiddenConfirmPassword = true;
  bool isSendOTP = false;
  final _auth = FirebaseAuth.instance;

  // form key
  final _formKey = GlobalKey<FormState>();
  //editing Controller
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final phoneEditingController = TextEditingController();
  final otpEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailAuth = EmailAuth(sessionName: "Nutri-Tracker");
    emailAuth.config(remoteServerConfiguration);
  }

  @override
  void dispose() {
    super.dispose();
    nameEditingController.dispose();
    emailEditingController.dispose();
    passwordEditingController.dispose();
    confirmPasswordEditingController.dispose();
    phoneEditingController.dispose();
    otpEditingController.dispose();
  }

  void sendOTP() async {
    var res = await emailAuth.sendOtp(
        recipientMail: emailEditingController.text, otpLength: 6);
    if (res) {
      Fluttertoast.showToast(msg: "OTP Sent Succesfully ");
    } else {
      Fluttertoast.showToast(msg: "Problem With Sending OTP");
    }
  }

  void verifyOTP() {
    var res = emailAuth.validateOtp(
        recipientMail: emailEditingController.text,
        userOtp: otpEditingController.value.text);
    if (res) {
      Fluttertoast.showToast(msg: "OTP verified!");
    } else {
      Fluttertoast.showToast(msg: "Invalid OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    //FirstName Text Field
    final nameField = TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter Your Name !");
        }
        //Regular Expression for name validation
        if (!RegExp(r"^[a-zA-Z\s]*$").hasMatch(value)) {
          return ("Enter Valid Name ");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    //phone no field
    final phoneField = TextFormField(
      autofocus: false,
      controller: phoneEditingController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter Your Phone Number !");
        }
        //Regular Expression for name validation
        if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
          return ("Enter Valid Phone Number ");
        } else if (value.length > 10 || value.length < 10) {
          return ("Enter Valid Phone Number");
        }
        return null;
      },
      onSaved: (value) {
        phoneEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.phone),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Mobile Number",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    //email Text Field

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter Your Email!");
        }
        //Regular Expression for email validation
        if (!RegExp(
                r"^[_A-Za-z0-9-\+]+(\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\.[A-Za-z0-9]+)*(\.[A-Za-z]{2,})$")
            .hasMatch(value)) {
          return ("Enter A Valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          suffix: SizedBox(
              height: 30,
              child: TextButton(
                onPressed: () {
                  isSendOTP = true;
                  sendOTP();
                },
                child: const Text("Send OTP"),
              )),
          prefixIcon: const Icon(Icons.email),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
    //otp text field
    final otpField = TextFormField(
      autofocus: false,
      controller: otpEditingController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter OTP !");
        }
        //Regular Expression for name validation
        if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
          return ("Enter Valid OTP ");
        } else if (value.length > 6 || value.length < 6) {
          return ("Enter Valid OTP");
        }
        return null;
      },
      onSaved: (value) {
        otpEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.sentiment_very_satisfied_outlined),
          suffix: SizedBox(
              height: 30,
              child: TextButton(
                onPressed: () {
                  verifyOTP();
                },
                child: const Text("Verify OTP"),
              )),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "OTP",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
    //Password Text Field
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: isHiddenPassword,
      controller: passwordEditingController,
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      validator: (value) {
        RegExp regex = RegExp(
            r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$).{8,20}$");
        if (value!.isEmpty) {
          return ("Password Is Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min.8 Character)");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          suffixIcon: InkWell(
            child: isHiddenPassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onTap: () {
              _togglePasswordView();
            },
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    //Confirm Password Text Field
    final confirmPasswordField = TextFormField(
      autofocus: false,
      obscureText: isHiddenConfirmPassword,
      controller: confirmPasswordEditingController,
      validator: (value) {
        if (passwordEditingController.text.length >= 8 &&
            passwordEditingController.text != value) {
          return "Password do'nt match";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          suffixIcon: InkWell(
            child: isHiddenConfirmPassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onTap: () {
              _toggleConfirmPasswordView();
            },
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    //signup button
    final signupButton = Material(
      color: Colors.green,
      elevation: 0,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        onPressed: () {
          signUp(emailEditingController.text, passwordEditingController.text);
        },
        child: const Text(
          'Signup',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.green,
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 160,
                        child: Image.asset(
                          "assets/images/Nutri.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      nameField,
                      const SizedBox(
                        height: 20,
                      ),
                      phoneField,
                      const SizedBox(
                        height: 20,
                      ),
                      emailField,
                      const SizedBox(
                        height: 20,
                      ),
                      if (isSendOTP) otpField,
                      if (isSendOTP)
                        const SizedBox(
                          height: 20,
                        ),
                      passwordField,
                      const SizedBox(
                        height: 20,
                      ),
                      confirmPasswordField,
                      const SizedBox(
                        height: 20,
                      ),
                      signupButton,
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        postDetailsToFirestore();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(msg: 'Email is already registered ');
        }
      }
    }
  }

  postDetailsToFirestore() async {
    // calling firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = nameEditingController.text;
    userModel.mobile = phoneEditingController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    Fluttertoast.showToast(msg: "Account Created succesfully");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => const homepage()),
        (route) => false);
  }

  void _togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      isHiddenConfirmPassword = !isHiddenConfirmPassword;
    });
  }
}
