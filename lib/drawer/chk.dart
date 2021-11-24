import 'package:flutter/material.dart';
import 'package:nutri_tracker/sharedPreferences/constant.dart';
import 'package:nutri_tracker/sharedPreferences/shared.dart';

class Chk extends StatefulWidget {
  const Chk({Key? key}) : super(key: key);

  @override
  _ChkState createState() => _ChkState();
}

class _ChkState extends State<Chk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('${DataConstant.gimg}')),
                  const SizedBox(width: 20),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DataConstant.gname.toString(),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DataConstant.gmail.toString(),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ])
                ],
              ),
            ),
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('${DataConstant.photo}')),
                  const SizedBox(width: 20),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DataConstant.name.toString(),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DataConstant.mail.toString(),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ])
                ],
              ),
            ),
          ),
          Column(
            children: [
              Text('${DataConstant.gimg}'),
              Text('${DataConstant.gname}'),
              Text('${DataConstant.gmail}'),
              Text('${DataConstant.photo}'),
              Text('${DataConstant.name}'),
              Text('${DataConstant.mail}'),
            ],
          ),
        ],
      ),
    );
  }
}
