import 'package:cloud_firestore/cloud_firestore.dart';
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
var userCategory = ['UnderWeight', 'OverWeight', 'Normal'];
late String selectedCategory = userCategory.first;
bool isCategoryChanged = false;
var subCategory = ['Fruits', 'Drinks', 'Meals'];
late String selectedSubCategory = subCategory.first;
bool isSubCategoryChanged = false;

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
                    //Categories dropdwon
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

                    //Sub category Dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
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
                            labelText: 'Sub Category',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                        value: selectedSubCategory,
                        // updateData.gender == ''    ? selectedGender: updateData.gender,
                        icon: Icon(Icons.arrow_drop_down,
                            color:
                                Theme.of(context).appBarTheme.foregroundColor),
                        iconSize: 26,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSubCategory = newValue!;
                            isSubCategoryChanged = !isSubCategoryChanged;
                          });
                          setState(() {});
                        },
                        isExpanded: false,
                        items: subCategory
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
                    const SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Name", Icons.title, nameController),
                    const SizedBox(
                      height: 10,
                    ),
                    selectedSubCategory == "Meals"
                        ? buildFormItems("Ingredients", Icons.description,
                            descriptionController)
                        : buildFormItems("Description", Icons.description,
                            descriptionController),
                    const SizedBox(
                      height: 10,
                    ),
                    buildFormItems("Nutritional Facts", Icons.fact_check_sharp,
                        nutriFactsController),
                    const SizedBox(
                      height: 10,
                    ),
                    selectedSubCategory == "Meals"
                        ? buildFormItems(
                            "Recipie", Icons.description, descriptionController)
                        : buildFormItems(
                            "Benifits", Icons.emoji_nature, benifitsController),
                    const SizedBox(
                      height: 10,
                    ),
                    selectedSubCategory == "Meals"
                        ? TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                hintText: "Not Required",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          )
                        : buildFormItems("Side Effects",
                            Icons.dangerous_outlined, sideEffectsController),
                    const SizedBox(
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
                                print(selectedCategory);
                                print(selectedSubCategory);
                                if (adminkey.currentState!.validate()) {
                                  addNutritionalData(
                                      selectedCategory,
                                      selectedSubCategory,
                                      imageURLController.text,
                                      nameController.text,
                                      descriptionController.text,
                                      nutriFactsController.text,
                                      benifitsController.text,
                                      sideEffectsController.text,
                                      context);
                                }
                              },
                              child: const Text("Add")),
                        ),
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
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

void addNutritionalData(
    String category,
    String subCat,
    String img,
    String name,
    String desc,
    String nfacts,
    String benifits,
    String sideEffects,
    BuildContext context) {
  var db = FirebaseFirestore.instance.collection("NutritionalData");
  Map<String, dynamic> addData = {
    "image": img,
    "name": name,
    "desc": desc,
    "nfact": nfacts,
    "benefits": benifits,
    "side_effects": sideEffects
  };

  Map<String, dynamic> addMeal = {
    "image": img,
    "name": name,
    "ingredients": desc,
    "nfact": nfacts,
    "recipie": benifits,
  };
  //add overweight data
  if (category == 'OverWeight') {
    if (subCat == 'Fruits') {
      db
          .doc("OverWeight")
          .collection('Fruits')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Drinks') {
      db
          .doc("OverWeight")
          .collection('Drinks')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Meals') {
      db
          .doc("OverWeight")
          .collection('Meals')
          .add(addMeal)
          .then((value) => print('success'));
    }
  }
  //Add underweight data
  if (category == 'UnderWeight') {
    if (subCat == 'Fruits') {
      db
          .doc("UnderWeight")
          .collection('Fruits')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Drinks') {
      db
          .doc("UnderWeight")
          .collection('Drinks')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Meals') {
      db
          .doc("UnderWeight")
          .collection('Meals')
          .add(addMeal)
          .then((value) => print('success'));
    }
  }

  //Add normal data
  if (category == 'Normal') {
    if (subCat == 'Fruits') {
      db
          .doc("Normal")
          .collection('Fruits')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Drinks') {
      db
          .doc("Normal")
          .collection('Drinks')
          .add(addData)
          .then((value) => print('success'));
    }
    if (subCat == 'Meals') {
      db
          .doc("Normal")
          .collection('Meals')
          .add(addMeal)
          .then((value) => print('success'));
    }
  }

  showConfirmationDialog(context);
}

showConfirmationDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("No"),
    onPressed: () {
      Navigator.pop(context);
      nameController.clear();
      imageURLController.clear();
      descriptionController.clear();
      nutriFactsController.clear();
      sideEffectsController.clear();
      benifitsController.clear();
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Yes"),
    onPressed: () {
      nameController.clear();
      imageURLController.clear();
      descriptionController.clear();
      nutriFactsController.clear();
      sideEffectsController.clear();
      benifitsController.clear();
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Data Added Successflly"),
    content: const Text("Do you want to add another data?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
