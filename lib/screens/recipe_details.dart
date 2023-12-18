// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/classes/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'edit_recipe.dart';

Future<bool> isRecipeSaved(String recipeId) async {
  try {
    User currentUser = FirebaseAuth.instance.currentUser!;
    String userEmail = currentUser.email!;
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('/users/$userEmail/createdRecipes')
        .doc(recipeId);

    final DocumentSnapshot snapshot = await documentReference.get();

    return snapshot.exists;
  } catch (error) {
    print('Error checking if recipe is saved: $error');
    return false;
  }
}

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback updatedSavedRecipes;
  late Future<bool> isUserCreated;

  int random = Random().nextInt(99);

  RecipeDetailsScreen({super.key, required this.recipe, required this.updatedSavedRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe Details',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 231, 80, 130),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              !recipe.strMealThumb.isNotEmpty
                  ? 'https://source.unsplash.com/random/?food?$random'
                  : recipe.strMealThumb,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            FutureBuilder<bool>(
              future: isRecipeSaved(recipe.idMeal),
              builder: (context, isSavedSnapshot) {
                if (isSavedSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (isSavedSnapshot.hasError) {
                  return Icon(Icons.error);
                } else {
                  bool isUserCreated = isSavedSnapshot.data ?? false;
                  if (isUserCreated) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            handleEditRecipe(context, recipe);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () {
                              handleDeleteRecipe(context, recipe.idMeal);
                            },
                            icon: Icon(Icons.delete)),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recipe.strMeal,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildIngredientWidgets(),
            ),
            SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              recipe.strInstructions,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientWidgets() {
    List<Widget> ingredientWidgets = [];

    for (int i = 0; i < recipe.ingredients.length; i++) {
      ingredientWidgets.add(
        Text(
          '${i + 1}. ${recipe.ingredients[i]} - ${recipe.measures.isNotEmpty ? recipe.measures[i] : ''}',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ingredientWidgets;
  }

  void handleEditRecipe(BuildContext context, Recipe recipe) {
    // Navigate to the screen where the user can edit the recipe
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(recipe: recipe, updatedSavedRecipes: updatedSavedRecipes),
      ),
    );
  }

  void handleDeleteRecipe(BuildContext context, String recipeId) async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser!;
      String userEmail = currentUser.email!;

      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection('/users/$userEmail/createdRecipes')
          .doc(recipeId);

      await documentReference.delete();
      updatedSavedRecipes();

      Navigator.pop(context);
    } catch (error) {
      print('Error deleting recipe: $error');
    }
  }
}
