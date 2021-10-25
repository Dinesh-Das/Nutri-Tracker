import 'package:flutter/material.dart';
import 'dietrylist/dietry_list.dart';

class diet extends StatelessWidget {
  const diet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.amber,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: const Icon(
            Icons.local_hospital,
            color: Colors.green,
            size: 35.0,
          ),
          title: const Text(
            'Diet',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        ),
        body: dietrylist());
  }
}
