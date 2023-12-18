// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/classes/recipe.dart';
import 'package:recipe_flutter_app/screens/create_recipe.dart';
import 'package:recipe_flutter_app/screens/profile_screen.dart';
import 'package:recipe_flutter_app/screens/recipe_list_screen.dart';
import 'package:recipe_flutter_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Recipe>> fetchRecipes(String searchRecipe) async {
  final response = await http.get(Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=$searchRecipe'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['meals'];
    return List<Recipe>.from(data.map((json) => Recipe.fromJson(json)));
  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<Recipe>> fetchSavedRecipes() async {
  try {
    User currentUser = FirebaseAuth.instance.currentUser!;
    String userEmail = currentUser.email!;
    final CollectionReference userSavedCollection =
        FirebaseFirestore.instance.collection('/users/$userEmail/userSaved');

    // Get the saved recipes from Firestore
    final QuerySnapshot snapshot = await userSavedCollection.get();
    final List<QueryDocumentSnapshot> documents = snapshot.docs;

    List<String> savedRecipeIds =  List<String>.from(documents.map((doc) => doc['recipe']));
    List<Recipe> recipes = [];

    for (String id in savedRecipeIds) {
      final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['meals'];
        if (data.isNotEmpty) {
          recipes.add(Recipe.fromJson(data[0]));
        }
      } else {
        throw Exception('Failed to load data');
      }
    }
    return recipes;
  } catch (error) {
    print('Error fetching saved recipes: $error');
    return [];
  }
}

Future<List<Recipe>> getCreatedRecipes() async {
  User currentUser = FirebaseAuth.instance.currentUser!;
  String userEmail = currentUser.email!;

  final CollectionReference userCreatedCollection =
      FirebaseFirestore.instance.collection('/users/$userEmail/createdRecipes');

  final QuerySnapshot snapshot = await userCreatedCollection.get();
  final List<QueryDocumentSnapshot> documents = snapshot.docs;

  return List<Recipe>.from(documents.map((doc) => Recipe.fromFirestore(doc)));
}

Future<List<String>> getSavedRecipesFromFirestore(String userEmail) async {
  final CollectionReference userSavedCollection =
      FirebaseFirestore.instance.collection('/users/$userEmail/userSaved');

  // Get the saved recipes from Firestore
  final QuerySnapshot snapshot = await userSavedCollection.get();
  final List<QueryDocumentSnapshot> documents = snapshot.docs;

  return List<String>.from(documents.map((doc) => doc['recipe']));
}

Future<List<Recipe>> getCreatedRecipesFromFirestore() async {
  final CollectionReference userSavedCollection =
      FirebaseFirestore.instance.collection('/userCreated');

  // Get the saved recipes from Firestore
  final QuerySnapshot snapshot = await userSavedCollection.get();
  final List<QueryDocumentSnapshot> documents = snapshot.docs;

  return List<Recipe>.from(documents.map((doc) => Recipe.fromFirestore(doc)));
}

Future<List<Recipe>> joinFutures(
    Future<List<Recipe>> future1, Future<List<Recipe>> future2) async {
  // Use Future.wait to wait for both futures to complete
  List<List<Recipe>> results = await Future.wait([future1, future2]);

  // Combine the results into a single list
  List<Recipe> combinedList = results.expand((list) => list).toList();

  return combinedList;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String searchRecipe = '';
  late Future<List<Recipe>> futureRecipes;
  late Future<List<Recipe>> allCreatedRecipes;
  late Future<List<Recipe>> createdRecipes;
  late Future<List<Recipe>> savedRecipesData;
  late Future<List<String>> savedRecipes;
  bool isSearching = false;
  int selectedIndex = 1;
  User? currentUser;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void searchRecipes(String query) {
    setState(() {
      isSearching = true;
      searchRecipe = query;
      futureRecipes = fetchRecipes(query);
    });
  }

  void handleUpdateSaved () {
    setState(() {
      savedRecipesData = fetchSavedRecipes();
    });
  }

  @override
  void initState() {
    super.initState();
    createdRecipes = getCreatedRecipes();
    futureRecipes = fetchRecipes('');
    currentUser = _authService.getCurrentUser();
    savedRecipes = getSavedRecipesFromFirestore(currentUser!.email!);
    savedRecipesData = fetchSavedRecipes();
    allCreatedRecipes = getCreatedRecipesFromFirestore();
  }

  void updateCreatedRecipes() {
    setState(() {
      createdRecipes = getCreatedRecipes();
    });
  }
  
  @override
  Widget build(BuildContext context){
    Widget body = Container(
    );
  
  switch (selectedIndex) {
      case 0:
        body =  CreateRecipeScreen(updateCreatedRecipes: updateCreatedRecipes);
      case 1:
        body =  RecipeListScreen(recipes: joinFutures(allCreatedRecipes, futureRecipes), handleUpdateSaved: handleUpdateSaved, updatedSavedRecipes: updateCreatedRecipes);
        break;
      case 2:
        body = RecipeListScreen(recipes: joinFutures(savedRecipesData, createdRecipes), handleUpdateSaved: handleUpdateSaved, updatedSavedRecipes: updateCreatedRecipes);
        break;
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 231, 80, 130),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Recipes',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 50.0),
            Expanded(
              child: TextField(
                onSubmitted: (value) => searchRecipes(value),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person),
            color: Colors.white,
          )
        ],
      ),
      backgroundColor: Colors.red[100],
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pink[300],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'Saved',
              activeIcon: Icon(Icons.favorite)),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.white, // Customize the selected item color
        unselectedItemColor: Colors.pink[900],
        onTap: onItemTapped,
      ),
    );
  }
}
