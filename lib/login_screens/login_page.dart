import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_tracker/admin/admin_home.dart';
import 'package:nutri_tracker/homepage/bottom_navigation.dart';
import 'package:nutri_tracker/login_screens/forgot_password.dart';
import 'package:nutri_tracker/database/google_signin.dart';
import 'package:nutri_tracker/login_screens/register_page.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHiddenPassword = true;

  //form key
  final _formKey = GlobalKey<FormState>();

  //editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Email Text Field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
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
        emailController.text = value!;
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
      controller: passwordController,
      validator: (value) {
        RegExp regex = RegExp(
            r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$).{8,20}$");

        if (value!.isEmpty) {
          return ("Password Is Required For Login");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min.8 Character)");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
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

    //Buttons
    final loginButton = Material(
      color: Colors.green,
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        onPressed: () {
          signIn(emailController.text, passwordController.text);
        },
        child: const Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
      ),
    );

    return Scaffold(
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
                        height: 200,
                        child: Image.asset(
                          "assets/images/Nutri.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      emailField,
                      const SizedBox(
                        height: 25,
                      ),
                      passwordField,
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()));
                          },
                          child: const Text("Forgot Password?")),
                      const SizedBox(
                        height: 5,
                      ),
                      loginButton,
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Dont't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen()));
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // const Text(
                      //   "OR",
                      //   style: TextStyle(
                      //       fontSize: 22, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      // //Signin With Google Button
                      // ElevatedButton.icon(
                      //     onPressed: () async {
                      //       ;
                      //       final provider = Provider.of<GoogleSignInProvider>(
                      //           context,
                      //           listen: false);
                      //       provider
                      //           .googleLogin()
                      //           .whenComplete(() => Navigator.pushReplacement(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       BottomNavigation())))
                      //           .catchError((error) {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(
                      //             content: Text('Error .......'),
                      //           ),
                      //         );
                      //       });
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //         primary: Colors.white54,
                      //         fixedSize: const Size(double.maxFinite, 55),
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(50))),
                      //     icon: Image.asset(
                      //       "assets/images/google_logo.png",
                      //       fit: BoxFit.fill,
                      //       height: 25,
                      //     ),
                      //     label: const Text(
                      //       "Sign Up With Google",
                      //       style: TextStyle(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 18),
                      //     )),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  //toggle passwordview
  void _togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  //login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      // nutritracker@admin.in
      try {
        UserLocalData.savePass(passwordController.text);
        UserLocalData.saveMail(emailController.text);

        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Login Successful'),
        ));

        //if admin go to admin page
        if (emailController.text == 'nutritracker@admin.in') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminPage()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavigation()));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found with that email.'),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong Password. Try again.'),
            ),
          );
        } else if (e.code == 'network-request-failed') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poor Internet Connection. Try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error occurred while signing in. Try again.'),
          ),
        );
      }
    }
  }
}
