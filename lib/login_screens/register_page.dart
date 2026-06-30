import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isHiddenPassword = true;
  bool isHiddenConfirmPassword = true;
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
  String? _verificationId;
  int? _forceResendingToken;
  PhoneAuthCredential? _phoneCredential;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _phoneVerified = false;

  @override
  void initState() {
    super.initState();
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
      keyboardType: TextInputType.phone,
      validator: _validatePhoneNumber,
      onChanged: (_) {
        if (_verificationId == null && _phoneCredential == null) return;
        setState(() {
          _verificationId = null;
          _forceResendingToken = null;
          _phoneCredential = null;
          _phoneVerified = false;
          otpEditingController.clear();
        });
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

    final otpField = TextFormField(
      autofocus: false,
      controller: otpEditingController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_phoneVerified) return null;
        if (_verificationId == null) return 'Send phone OTP first';
        if (value == null || value.trim().length < 6) {
          return 'Enter the OTP sent to your phone';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.sms_outlined),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Phone OTP",
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
          prefixIcon: const Icon(Icons.email),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
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
        return null;
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
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        child: const Text(
          'Signup',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _phoneVerified || _isSendingOtp
                                  ? null
                                  : _sendPhoneOtp,
                              icon: _isSendingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.sms_outlined),
                              label: Text(_verificationId == null
                                  ? 'Send OTP'
                                  : 'Resend OTP'),
                            ),
                          ),
                          if (_phoneVerified) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.verified, color: Colors.green),
                          ],
                        ],
                      ),
                      if (_verificationId != null && !_phoneVerified) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        otpField,
                        const SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: _isVerifyingOtp ? null : _verifyPhoneOtp,
                            icon: _isVerifyingOtp
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: const Text('Verify OTP'),
                          ),
                        ),
                      ],
                      const SizedBox(
                        height: 20,
                      ),
                      emailField,
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

  Future<void> _sendPhoneOtp() async {
    final validationMessage = _validatePhoneNumber(phoneEditingController.text);
    if (validationMessage != null) {
      _showAuthMessage(validationMessage);
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _firebasePhoneNumber,
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (credential) {
          if (!mounted) return;
          setState(() {
            _phoneCredential = credential;
            _phoneVerified = true;
            _isSendingOtp = false;
          });
          _showAuthMessage('Phone number verified automatically.');
        },
        verificationFailed: (error) {
          if (!mounted) return;
          setState(() => _isSendingOtp = false);
          _showAuthMessage(_phoneAuthErrorMessage(error));
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _forceResendingToken = resendToken;
            _phoneCredential = null;
            _phoneVerified = false;
            _isSendingOtp = false;
          });
          _showAuthMessage('OTP sent to $_firebasePhoneNumber.');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!mounted) return;
          setState(() => _verificationId = verificationId);
        },
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      _showAuthMessage(_phoneAuthErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      _showAuthMessage('Unable to send OTP. Check Firebase Phone Auth setup.');
    }
  }

  void _verifyPhoneOtp() {
    if (_verificationId == null) {
      _showAuthMessage('Send phone OTP first.');
      return;
    }
    if (otpEditingController.text.trim().length < 6) {
      _showAuthMessage('Enter the OTP sent to your phone.');
      return;
    }

    setState(() => _isVerifyingOtp = true);
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otpEditingController.text.trim(),
    );
    setState(() {
      _phoneCredential = credential;
      _phoneVerified = true;
      _isVerifyingOtp = false;
    });
    _showAuthMessage(
        'OTP captured. Complete signup to verify it with Firebase.');
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      if (_phoneCredential == null || !_phoneVerified) {
        _showAuthMessage('Verify phone OTP before signing up.');
        return;
      }
      try {
        UserLocalData.saveLoginData(true);
        UserLocalData.saveMail(emailEditingController.text);
        final phoneCredential = _phoneCredential!;
        final credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        final user = credential.user ?? _auth.currentUser;
        try {
          await user?.linkWithCredential(phoneCredential);
        } on FirebaseAuthException {
          try {
            await user?.delete();
          } catch (_) {
            await _auth.signOut();
          }
          rethrow;
        }
        var verificationEmailSent = false;
        try {
          await user?.sendEmailVerification();
          verificationEmailSent = true;
        } on FirebaseAuthException catch (error) {
          debugPrint('Unable to send verification email: ${error.code}');
        }
        await postDetailsToFirestore(
          verificationEmailSent: verificationEmailSent,
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email Already in use'),
            ),
          );
        } else if (e.code == 'credential-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('This phone number is already linked to an account.'),
            ),
          );
        } else if (e.code == 'invalid-verification-code' ||
            e.code == 'invalid-credential') {
          setState(() {
            _phoneCredential = null;
            _phoneVerified = false;
            otpEditingController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please resend and try again.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Registration failed')),
          );
        }
      }
    }
  }

  Future<void> postDetailsToFirestore({
    required bool verificationEmailSent,
  }) async {
    // calling firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = nameEditingController.text;
    userModel.mobile = _firebasePhoneNumber;
    userModel.isOnboardingDone = false;

    await firebaseFirestore
        .collection("user_details")
        .doc(user.uid)
        .set(userModel.toMap());

    await _auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        verificationEmailSent
            ? 'Account created. Please verify your email from the link in your inbox.'
            : 'Account created, but the verification email was not sent. Sign in once to resend it.',
      ),
    ));

    context.go(AppRoutes.login);
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

  String? _validatePhoneNumber(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Enter Your Phone Number !';
    }
    if (phone.startsWith('+')) {
      return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)
          ? null
          : 'Enter phone in E.164 format';
    }
    return RegExp(r'^[0-9]{10}$').hasMatch(phone)
        ? null
        : 'Enter Valid Phone Number';
  }

  String get _firebasePhoneNumber {
    final phone = phoneEditingController.text.trim();
    return phone.startsWith('+') ? phone : '+91$phone';
  }

  String _phoneAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Enter a valid phone number with country code.';
      case 'too-many-requests':
        return 'Too many OTP requests. Try again later.';
      case 'quota-exceeded':
        return 'Firebase SMS quota exceeded.';
      case 'operation-not-allowed':
        return 'Enable Phone provider in Firebase Authentication.';
      default:
        return error.message ?? 'Unable to send OTP. Check Firebase setup.';
    }
  }

  void _showAuthMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
