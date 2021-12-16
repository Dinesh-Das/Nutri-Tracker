import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewData extends StatefulWidget {
  const ViewData({Key? key}) : super(key: key);

  @override
  _ViewDataState createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("user_details")
            // .collection("NutritionalData")
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            print("total documents : ${snapshot.data!.docs.length}");
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.separated(
                itemBuilder: (context, int index) {
                  Map<String, dynamic> doc = snapshot.data!.docs[index].data();
                  if (doc.isEmpty) {
                    return Center(child: Text("document is empty"));
                  }
                  String name =
                      snapshot.data!.docs.elementAt(index).get("name");
                  return ListTile(
                    title: Text(name),
                    subtitle: Text("data"),
                  );
                },
                separatorBuilder: (___, ____) {
                  return Divider();
                },
                itemCount: snapshot.data!.docs.length,
              );
            } else {
              return Center(
                child: Text("Documents are not available"),
              );
            }
          } else {
            return Center(child: Text("Error"));
          }
        },
      )),
    );
  }
}
