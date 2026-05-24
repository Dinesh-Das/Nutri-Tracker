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
            .collection("food_data")
            .orderBy('createdAt', descending: true)
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
                  final name = (doc["name"] ?? "Food").toString();
                  final img =
                      (doc["imageURL"] ?? doc["image"] ?? "").toString();
                  return ListTile(
                    leading: img.isEmpty
                        ? const Icon(Icons.restaurant)
                        : Image.network(img),
                    title: Text(name),
                    subtitle: Text(
                      '${doc["category"] ?? ""} / ${doc["subCategory"] ?? ""}',
                    ),
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
