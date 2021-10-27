// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

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
                      // trailing: Image.asset('icons/icons8-apple-50.png'),
                      // trailing: Icon(
                      //   Icons.add_task_outlined,
                      //   size: 24.0,
                      // ),
                    ),
                  ))),
          Positioned(
              // Posiioned container
              top: 350,
              left: 10,
              right: 10,
              height: height * .45,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(60.0)),
                child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    // container for adding icons
                    color: Colors.greenAccent.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon:
                                    Icon(Icons.music_note_outlined, size: 50.0),
                                tooltip: 'Music On',
                                color: Colors.red[500],
                              ),
                              IconButton(
                                onPressed: () {},
                                tooltip: 'Music OFF',
                                color: Colors.redAccent,
                                icon: Icon(Icons.music_off, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Worke Done',
                                icon: Icon(Icons.done_all_sharp, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Call',
                                icon: Icon(Icons.call, size: 50.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 50.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon:
                                    Icon(Icons.music_note_outlined, size: 50.0),
                                tooltip: 'Music On',
                                color: Colors.red[500],
                              ),
                              IconButton(
                                onPressed: () {},
                                tooltip: 'Music OFF',
                                color: Colors.redAccent,
                                icon: Icon(Icons.music_off, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Worke Done',
                                icon: Icon(Icons.done_all_sharp, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Call',
                                icon: Icon(Icons.call, size: 50.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 50.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon:
                                    Icon(Icons.music_note_outlined, size: 50.0),
                                tooltip: 'Music On',
                                color: Colors.red[500],
                              ),
                              IconButton(
                                onPressed: () {},
                                tooltip: 'Music OFF',
                                color: Colors.redAccent,
                                icon: Icon(Icons.music_off, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Worke Done',
                                icon: Icon(Icons.done_all_sharp, size: 50.0),
                              ),
                              IconButton(
                                onPressed: () {},
                                color: Colors.green,
                                tooltip: 'Call',
                                icon: Icon(Icons.call, size: 50.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
              )),
        ],
      ),
    );
  }
}
