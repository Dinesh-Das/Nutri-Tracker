// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_tracker/onbparding_components/content_model.dart';
import 'package:nutri_tracker/auth_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentIndex = 0;
  late PageController _controller;
  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
    
  }
  @override
  void dispose() {
    
    _controller.dispose();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
        body:  Column(
      children: [
        Expanded(
          child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        contents[i].image,
                        height: 400,
                      ),
                      Text(
                        contents[i].title,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        contents[i].description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      )
                    ],
                  ),
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              contents.length, (index) => buildDot(index, context)),
        ),
        Container(
          height: 55,
          margin: const EdgeInsets.all(40),
          width: double.infinity,
          // ignore: deprecated_member_use
          child: FlatButton(
            child:
                Text(currentIndex == contents.length - 1 ? "Continue" : "Next"),
            onPressed: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) =>  const AuthScreen()
                    )
                  );
              }
              _controller.nextPage(
                duration: const Duration(microseconds: 100),
                curve: Curves.bounceIn,
              );
            },
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )
      ],
    ));
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 20 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
