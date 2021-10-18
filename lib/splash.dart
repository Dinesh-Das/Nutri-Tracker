import 'package:flutter/material.dart';
import 'package:nutri_tracker/onbparding_components/Onboarding.dart';
class Splash extends StatefulWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState()
  {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome()async
  {
    await Future.delayed(const Duration(milliseconds: 7200),(){});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Onboarding()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[Image.asset('assets/images/splash_light.gif'),
            
          ]),
      ),
      
    );
  }
}