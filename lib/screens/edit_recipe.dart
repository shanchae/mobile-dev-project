// ignore_for_file: prefer_final_fields, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/classes/recipe.dart';

import 'recipe_details.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback updatedSavedRecipes;

  const EditRecipeScreen({Key? key, required this.recipe, required this.updatedSavedRecipes}) : super(key: key);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  TextEditingController _ingredientsController = TextEditingController();

  List<String> ingredients = [];
  List<String> measures = [];

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with the existing recipe details
    _nameController.text = widget.recipe.strMeal;
    _instructionsController.text = widget.recipe.strInstructions;
    _ingredientsController.text = widget.recipe.ingredients.join(', ');
    ingredients = widget.recipe.ingredients;
    measures = widget.recipe.measures;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 231, 80, 130),
        title: Text(
          'Edit Recipe',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
        ),
      ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _instructionsController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Instructions'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ingredientsController,
                decoration:
                    InputDecoration(labelText: 'Ingredients (comma-separated)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _addIngredients();
                },
                child: Text('Add Ingredients'),
              ),
              SizedBox(height: 16),
              Text('Ingredients: ${ingredients.join(', ')}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateRecipe();
                },
                child: Text('Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredients() {
    String input = _ingredientsController.text.trim();
    List<String> newIngredients =
        input.split(',').map((e) => e.trim()).toList();
    ingredients.addAll(newIngredients);
    _ingredientsController.clear();
    setState(() {});
  }

  void _updateRecipe() async {
    String name = _nameController.text.trim();
    String instructions = _instructionsController.text.trim();

    if (name.isNotEmpty && instructions.isNotEmpty && ingredients.isNotEmpty) {
      // Create an updated recipe object
      Recipe updatedRecipe = Recipe(
        idMeal: widget.recipe.idMeal,
        strMeal: name,
        strMealThumb: widget.recipe.strMealThumb,
        strInstructions: instructions,
        strTags: widget.recipe.strTags,
        strYoutube: widget.recipe.strYoutube,
        ingredients: ingredients,
        measures: measures,
      );

      // Perform the update operation
      await updateDataInFirestore(updatedRecipe);
      widget.updatedSavedRecipes();
      // Inform the user that the recipe has been updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe updated successfully!'),
        ),
      );

      // Navigate back to the previous screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailsScreen(recipe: updatedRecipe, updatedSavedRecipes: widget.updatedSavedRecipes)));
    } else {
      // Inform the user that some fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
    }
  }

  Future<void> updateDataInFirestore(Recipe updatedRecipe) async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser!;
      String userEmail = currentUser.email!;

      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection('/users/$userEmail/createdRecipes')
          .doc(updatedRecipe.idMeal);

      await documentReference.update(updatedRecipe.toMap());

      print('Data updated in Firestore successfully!');
    } catch (error) {
      print('Error updating data in Firestore: $error');
    }
  }
}
