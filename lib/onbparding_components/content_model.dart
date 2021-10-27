// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

class ItemData {
  final Color color;
  final String image;
  final String title;
  final String description;

  ItemData(this.color, this.image, this.title, this.description);
}

List<ItemData> data = [
  ItemData(const Color(0xFFF9bcbe2), "assets/onboard/6.jpg", "Nutrition Tips",
      "Get Best of Doctors Nutritious Tips"),
  ItemData(const Color(0xFFFc4e6e5), "assets/onboard/7.jpg",
      "Get Healthy Food Recipe", "A healthy outside starts from the inside."),
  ItemData(
      const Color(0xFFFffffff),
      "assets/onboard/8.jpg",
      "Regular health progress",
      "When something is delicious, it's zero calories."),
  ItemData(
      const Color(0xFFFf4c4c4),
      "assets/onboard/9.jpg",
      "Get Healthy Diet Recipe",
      "When diet is wrong, medicine is of no use. When diet is correct, medicine is of no need."),
  ItemData(const Color(0xFFFffffff), "assets/onboard/10.jpg",
      "Let's get Started", ""),
];
