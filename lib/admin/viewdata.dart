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
            .collection("NutritionalData")
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.separated(
                itemBuilder: (context, int index) {
                  return ListTile(
                    title: Text("data"),
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
