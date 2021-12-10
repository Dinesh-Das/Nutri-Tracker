import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/admin/admin_home.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddData extends StatefulWidget {
  const AddData({Key? key}) : super(key: key);

  @override
  _AddDataState createState() => _AddDataState();
}

final adminkey = GlobalKey<FormState>();
TextEditingController imageURLController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
TextEditingController nutriFactsController = TextEditingController();
TextEditingController benifitsController = TextEditingController();
TextEditingController sideEffectsController = TextEditingController();
var userCategory = ['Under-Weight', 'Over-Weight', 'Normal'];
late String selectedCategory = userCategory.first;
bool isCategoryChanged = false;

class _AddDataState extends State<AddData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin-Panel"),
        actions: [
          IconButton(
              onPressed: () async {
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.clear();
                sharedPreferences.remove('logintype');
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout)),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: adminkey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            prefixIcon: Icon(
                              Icons.group_outlined,
                              color: Theme.of(context).iconTheme.color,
                              size: 32,
                            ),
                            labelText: 'User Category Update',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                        value: selectedCategory,
                        // updateData.gender == ''    ? selectedGender: updateData.gender,
                        icon: Icon(Icons.arrow_drop_down,
                            color:
                                Theme.of(context).appBarTheme.foregroundColor),
                        iconSize: 26,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                            isCategoryChanged = !isCategoryChanged;
                          });
                        },
                        isExpanded: false,
                        items: userCategory
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    buildFormItems(
                        "Image URL", Icons.image, imageURLController),
                    SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Name", Icons.title, nameController),
                    SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Description", Icons.description,
                        descriptionController),
                    SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Nutritional Facts", Icons.fact_check_sharp,
                        nutriFactsController),
                    SizedBox(
                      height: 10,
                    ),
                    buildFormItems(
                        "Benifits", Icons.emoji_nature, benifitsController),
                    SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Side Effects", Icons.dangerous_outlined,
                        sideEffectsController),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () {
                                //Upload data
                              },
                              child: Text("Save")),
                        ),
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminPage()));
                              },
                              child: Text("Cancel")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildFormItems(
      String hint, IconData iconData, TextEditingController controller) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter $hint!");
        }
        return null;
      },
      onSaved: (value) {
        controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(
            iconData,
            color: Theme.of(context).iconTheme.color,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
