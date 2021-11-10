import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/AboutUs/data_developers.dart';
import 'package:nutri_tracker/drawer/AboutUs/viewabout.dart';

class Aboutus01 extends StatelessWidget {
  const Aboutus01({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About Us'),
        ),
        body: ListView.builder(
            itemCount: devList.length,
            itemBuilder: (context, index) {
              About about2 = devList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAbout(
                              about1: about2,
                            )),
                  );
                },
                child: Card(
                    child: ListTile(
                      title: Text(about2.name),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(about2.mail),
                            Text(about2.role),
                          ]),
                      leading: Hero(
                          tag: Key(about2.name),
                          child: Image.asset(about2.image)),
                      trailing: const Icon(Icons.arrow_right_rounded),
                    ),
                    elevation: 8,
                    shadowColor: Colors.purple.shade900,
                    margin: const EdgeInsets.all(20),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white))),
              );
            }));
  }
}
