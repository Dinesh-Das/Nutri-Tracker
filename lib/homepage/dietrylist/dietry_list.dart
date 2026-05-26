// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nutri_tracker/themes.dart';
import 'package:nutri_tracker/widgets/cached_app_image.dart';

class dietrylist extends StatelessWidget {
  const dietrylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Veggies',
                style: TextStyle(
                    color: MyColors.heading,
                    fontSize: 35,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Container(
                        color: Colors.blueGrey.withOpacity(0.2),
                        height: 150,
                        width: 350,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.35),
                                  BlendMode.multiply),
                              fit: BoxFit.cover,
                              image: cachedNetworkImageProvider(
                                  "https://images.unsplash.com/photo-1630855907465-99267502dfbd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1974&q=80"),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Container(
                      color: Colors.blueGrey.withOpacity(0.2),
                      height: 150,
                      width: 350,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Snow Peas',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Container(
                      color: Colors.blueGrey.withOpacity(0.2),
                      height: 150,
                      width: 350,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Cucumber',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Container(
                      color: Colors.blueGrey.withOpacity(0.2),
                      height: 150,
                      width: 350,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Cabbage',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Container(
                      color: Colors.blueGrey.withOpacity(0.2),
                      height: 150,
                      width: 350,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Brokoli',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
