import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/AboutUs/data_developers.dart';

class ViewAbout extends StatelessWidget {
  const ViewAbout({Key? key, required this.about1}) : super(key: key);
  final About about1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(about1.name),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: Key(about1.name),
                  child:
                      Image.asset(about1.image, height: 450, fit: BoxFit.fill),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    about1.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15.0, fontStyle: FontStyle.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    about1.mail,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 12.0, fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    about1.role,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 12.0, fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    about1.address,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 12.0, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ])),
    );
  }
}
