// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nutri_tracker/screens/RecipePage/models/recipe.api.dart';
import 'package:nutri_tracker/screens/RecipePage/models/recipe.dart';
import 'package:nutri_tracker/screens/RecipePage/widgets/recipe_card.dart';
import 'package:nutri_tracker/screens/themes.dart';

class recipe extends StatefulWidget {
  @override
  _recipeState createState() => _recipeState();
}

class _recipeState extends State<recipe> {
  late List<Recipe> _recipes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getRecipes();
  }

  Future<void> getRecipes() async {
    _recipes = await RecipeApi.getRecipe();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Icon(Icons.restaurant_menu, color: MyColors.iconsColor),
              SizedBox(width: 10),
              Text(
                'Food Recipe',
                style: TextStyle(color: MyColors.subHeading),
              )
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                      title: _recipes[index].name,
                      cookTime: _recipes[index].totalTime,
                      rating: _recipes[index].rating.toString(),
                      thumbnailUrl: _recipes[index].images);
                },
              ));
  }
}
