// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/classes/recipe.dart';
import 'package:recipe_flutter_app/screens/recipe_details.dart';
import 'package:recipe_flutter_app/services/auth_service.dart';

Future<void> saveRecipeToFirestore(Recipe recipe, String userEmail) async {
  final CollectionReference userSavedCollection =
      FirebaseFirestore.instance.collection('/users/$userEmail/userSaved');

  String recipeData = recipe.idMeal;

  await userSavedCollection.doc(recipeData).set({
      'recipe': recipeData,
      // Add other fields as needed
  });
}

Future<void> removeRecipeToFireStore(Recipe recipe, String userEmail) async {
  final DocumentReference userSavedCollection = FirebaseFirestore.instance
      .collection('users/$userEmail/userSaved').doc(recipe.idMeal);

  await userSavedCollection.delete();
}

class RecipeListScreen extends StatefulWidget {
  final Future<List<Recipe>> recipes;
  final VoidCallback handleUpdateSaved;
  final VoidCallback updatedSavedRecipes;
  
  RecipeListScreen({Key? key, required this.recipes, required this.handleUpdateSaved, required this.updatedSavedRecipes}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final AuthService _authService = AuthService();
  late User? currentUser;
  int random = Random().nextInt(99);

  @override
  void initState() {
    super.initState();
    currentUser = _authService.getCurrentUser();
  }
  
  Future<bool> isRecipeSaved(String userEmail, String recipeId) async {
    try {
      final CollectionReference userSavedCollection =
          FirebaseFirestore.instance.collection('/users/$userEmail/userSaved');

      final QuerySnapshot snapshot =
          await userSavedCollection.where('recipe', isEqualTo: recipeId).get();

      return snapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking if recipe is saved: $error');
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: widget.recipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No recipes found.');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Recipe recipe = snapshot.data![index];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsScreen(
                                recipe: recipe, updatedSavedRecipes: widget.updatedSavedRecipes,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          !recipe.strMealThumb.isNotEmpty ? 'https://source.unsplash.com/random/?food?$random' : recipe.strMealThumb,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 20.0),
                          Text(
                            recipe.strMeal,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          FutureBuilder<bool>(
                            future: isRecipeSaved(
                                currentUser!.email!, recipe.idMeal),
                            builder: (context, isSavedSnapshot) {
                              if (isSavedSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (isSavedSnapshot.hasError) {
                                return Icon(Icons.error);
                              } else {
                                bool isSaved = isSavedSnapshot.data ?? false;
                                return IconButton(
                                  onPressed: () {
                                    widget.handleUpdateSaved();
                                    setState(() {
                                      if (isSaved) {
                                        removeRecipeToFireStore(
                                            recipe, currentUser!.email!);
                                      } else {
                                        saveRecipeToFirestore(
                                            recipe, currentUser!.email!);
                                      }
                                    });
                                  },
                                  icon: isSaved
                                      ? Icon(Icons.bookmark)
                                      : Icon(Icons.bookmark_border),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
