import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Verify OTP
class VerifyEmail extends StatefulWidget {
  const VerifyEmail({
    Key? key,
  }) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  late EmailAuth emailAuth;
  final emailEditingController = TextEditingController();
  final otpEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailAuth = new EmailAuth(
      sessionName: "Sample session",
    );
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/nutri.png",
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
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
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                hintText: "Enter OTP ",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionChip(
                  label: const Text("Send OTP"), onPressed: () => sendOTP()),
              const SizedBox(
                width: 20,
              ),
              ActionChip(
                  label: const Text("verify"), onPressed: () => verifyOTP())
            ],
          ),
        ],
      ),
    );
  }
}
