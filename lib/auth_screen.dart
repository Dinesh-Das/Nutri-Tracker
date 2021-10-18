import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/login_components/login_form.dart';
import 'package:nutri_tracker/login_components/sign_up_form.dart';
import 'package:nutri_tracker/login_components/socal_buttons.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  //if we want to show our signp then we set it true
  bool _isShowSignUp = false;

  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView()
  {
    setState(() {
      _isShowSignUp = !_isShowSignUp;
    });
    _isShowSignUp ? _animationController.forward() : _animationController.reverse();

  }

  @override
  void initState() {
    setUpAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // It provides height and witdth of the screen
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(  
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
              // login
              AnimatedPositioned(
                duration: defaultDuration,
                //we use 88% width for login
                width: _size.width * 0.88
                ,
                height: _size.height,
                left: _isShowSignUp ? -_size.width * 0.76 : 0,
                child: Container(
                  color: login_bg,
                  child: const LoginForm(),
                ),
              ),
              //Signup
              AnimatedPositioned(
                  duration: defaultDuration,
                  height: _size.height,
                  width: _size.width * 0.88,
                  left: _isShowSignUp ? _size.width * 0.12 : _size.width * 0.88,
                  child: Container(
                    color: signup_bg,
                    child: const SignUpForm(),
                  )),
      
              // Logo above login
              AnimatedPositioned(
                  duration: defaultDuration,
                  top: _size.height * 0.1,
                  left: 0,
                  right: _isShowSignUp ? -_size.width * 0.06 : _size.width * 0.09,
                  child: AnimatedSwitcher(
                    duration: defaultDuration,

                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black87,
                      child: _isShowSignUp
                          ? SvgPicture.asset(
                              "assets/images/Nutri.svg",
                              color: signup_bg,
                            )
                          : SvgPicture.asset(
                              "assets/images/Nutri.svg",
                              color: login_bg,
                            ),
                    ),
                  )),
      
              AnimatedPositioned(
                duration: defaultDuration,
                width: _size.width ,
                bottom: _size.height * 0.1,
                right: _isShowSignUp ? -_size.width * 0.06 : _size.width * 0.06,
                child: const SocalButtons(),
              ),
      
              // login text
              AnimatedPositioned(
                  duration: defaultDuration,
                  bottom: _isShowSignUp ? _size.height / 2  : _size.height * 0.3,
                  left: _isShowSignUp ? 0 : _size.width * 0.5 -80,
                  child: AnimatedDefaultTextStyle(
                    duration: defaultDuration,
                   // textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: _isShowSignUp ? 20 : 36,
                        fontWeight: FontWeight.bold,
                        color: _isShowSignUp ? Colors.black87 : Colors.black
                        ),
                    child: Transform.rotate(
                      angle: -_animationTextRotate.value * pi / 180,
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: (){
                           if(_isShowSignUp)
                           {
                             updateView();
                           }
                           else{
                             //login
                           }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: defpaultPadding * 0.75),
                          width: 160,
                          child: Text(
                            "Log In".toUpperCase()
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),

                  // Signup Text
                  AnimatedPositioned(
                  duration: defaultDuration,
                  bottom: !_isShowSignUp ? _size.height / 2 - 80: _size.height * 0.3,
                  right: !_isShowSignUp ? 0: _size.width * 0.4  - 80 ,
                  child: AnimatedDefaultTextStyle(
                    duration: defaultDuration,
                   // textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: !_isShowSignUp ? 20 : 32,
                        fontWeight: FontWeight.bold,
                        color: !_isShowSignUp ? Colors.black87 : Colors.black
                        ),
                    child: Transform.rotate(
                      angle:(90 -_animationTextRotate.value )* pi / 180,
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: (){
                          if(_isShowSignUp)
                          {
                            //sign up
                          }
                          else{
                            updateView();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: defpaultPadding * 0.75),
                          width: 160,
                          child: Text(
                            "Sign Up".toUpperCase()
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
            ],
          );
        }
      ),
    );
  }
}
