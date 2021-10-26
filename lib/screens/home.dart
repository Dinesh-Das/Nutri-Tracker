// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //       appBar: AppBar(
    //         elevation: 0,
    //         backgroundColor: Colors.transparent,
    //         leading: const Icon(
    //           Icons.home_outlined,
    //           color: Colors.purple,
    //           size: 35.0,
    //         ),
    //         title: const Text(
    //           'Home',
    //           style: TextStyle(color: Colors.black, fontSize: 25),
    //         ),
    //       ),
    //       backgroundColor: Colors.white);
    // }
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.40,
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40)),
                  child: Container(
                    padding:
                        EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
                    color: Colors.white,
                    child: ListTile(
                      leading: ClipOval(
                        child: Image.asset('assets/images/Nutri.png'),
                      ),
                      title: Text(
                        'Nutri-Tracker',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'We serve Happiness',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400),
                      ),
                      // trailing: Icon(
                      //   Icons.add_task_outlined,
                      //   size: 24.0,
                      // ),
                    ),
                  )))
        ],
      ),
    );
  }
}
