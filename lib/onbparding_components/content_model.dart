import 'package:flutter/material.dart';

class ItemData {
  final Color color;
  final String image;
  final String title;
  final String description;

  ItemData(this.color, this.image, this.title, this.description);
}
List<ItemData> data = [
    ItemData(Colors.blue, "assets/onboard/1.png", "Onboarding Page 1", "Onboarding Description Space 1"),
    ItemData(Colors.deepPurpleAccent, "assets/onboard/2.png","Onboarding Page 2", "Onboarding Description Space 2"),
    ItemData(Colors.green, "assets/onboard/3.png", "Onboarding Page 3", "Onboarding Description Space 3"),
    ItemData(Colors.yellow, "assets/onboard/4.png", "Onboarding Page 4", "Onboarding Description Space 4"),
    ItemData(Colors.red, "assets/onboard/5.png", "Onboarding Page 5", "Onboarding Description Space 5"),
  ];