import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/onbparding_components/content_model.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int page = 0;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  continueToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - (page - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return SizedBox(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: SizedBox(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            PageView.builder(
              controller: pageController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  width: double.infinity,
                  color: data[index].color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      //Image asset
                      Image.asset(
                        data[index].image,
                        height: 400,
                        fit: BoxFit.contain,
                      ),
                      // Text and description
                      Column(
                        children: <Widget>[
                          Text(
                            data[index].title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontFamily: "Billy",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Text(
                            data[index].description,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: "Billy",
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: pageChangeCallback,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(data.length, _buildDot),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: TextButton(
                  onPressed: () {
                    if (page != 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      pageController.animateToPage(
                        data.length - 1,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: page != 0
                      ? const Text("Back",
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : const Text(
                          "Skip",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  // color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: TextButton(
                  onPressed: () {
                    if (page + 1 > data.length - 1) {
                      continueToLogin();
                    } else {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: page + 1 > data.length - 1
                      ? const Text("Continue",
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : const Text("Next",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  // color: Colors.white.withOpacity(0.01),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
