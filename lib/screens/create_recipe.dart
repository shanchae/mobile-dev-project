// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/classes/recipe.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

Future<String?> uploadImage(PickedFile pickedImage, String fileName) async {
  try {
    final firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images')
        .child(fileName);

    final metadata = firebase_storage.SettableMetadata(
      contentType:
          'image/jpeg/png', // Adjust the content type based on your image type
    );

    final uploadTask = storageRef.putFile(File(pickedImage.path), metadata);

    await uploadTask.whenComplete(() => print('Image uploaded'));

    final String downloadURL = await storageRef.getDownloadURL();

    return downloadURL;
  } catch (error) {
    print('Error uploading image: $error');
    return null;
  }
}

Future<void> saveDataToFirestore(Recipe recipe) async {
  try {
    User currentUser = FirebaseAuth.instance.currentUser!;
    String userEmail = currentUser.email!;

    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('userCreated');

    final CollectionReference userSavedCollection =
        FirebaseFirestore.instance.collection('/users/$userEmail/createdRecipes');

    Map<String, dynamic> recipeData = {
      'idMeal': recipe.idMeal,
      'strMeal': recipe.strMeal,
      'strMealThumb': recipe.strMealThumb,
      'strInstructions': recipe.strInstructions,
      'strTags': recipe.strTags,
      'strYoutube': recipe.strYoutube,
      'ingredients': recipe.ingredients,
      'measures': recipe.measures,
    };

    await collectionReference.add(recipeData);

    await userSavedCollection.add({
      'recipe': recipe.idMeal,
      'strMeal': recipe.strMeal,
      'strMealThumb': recipe.strMealThumb,
      'strInstructions': recipe.strInstructions,
      'strTags': recipe.strTags,
      'strYoutube': recipe.strYoutube,
      'ingredients': recipe.ingredients,
      'measures': recipe.measures,
      // Add other fields as needed
    });
    
    print('Data saved to Firestore successfully!');
  } catch (error) {
    print('Error saving data to Firestore: $error');
  }
}

class CreateRecipeScreen extends StatefulWidget {
  final VoidCallback updateCreatedRecipes;
  const CreateRecipeScreen({super.key, required this.updateCreatedRecipes});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  TextEditingController _ingredientsController = TextEditingController();

  List<String> ingredients = [];
  List<String> measures = [];

  PickedFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile as PickedFile?;
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            _pickedImage != null
                ? Image.file(File(_pickedImage!.path))
                : Container(),
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
                _createRecipe();
              },
              child: Text('Create Recipe'),
            ),
          ],
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
  }

  void _createRecipe() async {
    String name = _nameController.text.trim();
    String instructions = _instructionsController.text.trim();
    String? imageURL;

    if (_pickedImage != null) {
      imageURL = await uploadImage(_pickedImage!, name);
    }

    if (name.isNotEmpty && instructions.isNotEmpty && ingredients.isNotEmpty) {
      Recipe newRecipe = Recipe(
        idMeal: name, // You might generate a unique ID here
        strMeal: name,
        strMealThumb: imageURL ?? '', // Replace with an actual image URL
        strInstructions: instructions,
        strTags: 'Tags', // Replace with actual tags
        ingredients: ingredients,
        measures: measures, 
        strYoutube: '', // You might want to get measures in a similar way as ingredients
      );

      await saveDataToFirestore(newRecipe);
      widget.updateCreatedRecipes();

      _nameController.clear();
      _instructionsController.clear();
      _ingredientsController.clear();
      ingredients.clear();
      measures.clear();

      // Inform the user that the recipe has been created (you can use a SnackBar or navigate to another screen)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe created successfully!'),
        ),
      );
    } else {
      // Inform the user that some fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
    }
  }
}
