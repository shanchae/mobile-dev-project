import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strInstructions;
  final String strTags;
  final String strYoutube;
  final List<String> ingredients;
  final List<String> measures;

  Recipe({
    required this.idMeal,
    required this.strMeal,
    required this.strInstructions,
    required this.strTags,
    required this.strMealThumb,
    required this.strYoutube,
    required this.ingredients,
    required this.measures,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      idMeal: json['idMeal'] as String? ?? 'NULL',
      strMeal: json['strMeal'] as String? ?? 'NULL',
      strMealThumb: json['strMealThumb'] as String? ?? 'NULL',
      strInstructions: json['strInstructions'] as String? ?? 'NULL',
      strTags: json['strTags'] as String? ?? 'NULL',
      strYoutube: json['strYoutube'] as String? ?? 'NULL',
      ingredients: [
        json['strIngredient1'] as String? ?? 'NULL',
        json['strIngredient2'] as String? ?? 'NULL',
        json['strIngredient3'] as String? ?? 'NULL',
        json['strIngredient4'] as String? ?? 'NULL',
        json['strIngredient5'] as String? ?? 'NULL',
        json['strIngredient6'] as String? ?? 'NULL',
        json['strIngredient7'] as String? ?? 'NULL',
        json['strIngredient8'] as String? ?? 'NULL',
        json['strIngredient9'] as String? ?? 'NULL',
        json['strIngredient10'] as String? ?? 'NULL',
        json['strIngredient11'] as String? ?? 'NULL',
        json['strIngredient12'] as String? ?? 'NULL',
        json['strIngredient13'] as String? ?? 'NULL',
        json['strIngredient14'] as String? ?? 'NULL',
        json['strIngredient15'] as String? ?? 'NULL',
        json['strIngredient16'] as String? ?? 'NULL',
        json['strIngredient17'] as String? ?? 'NULL',
        json['strIngredient18'] as String? ?? 'NULL',
        json['strIngredient19'] as String? ?? 'NULL',
        json['strIngredient20'] as String? ?? 'NULL',
      ],
      measures: [
        json['strMeasure1'] as String? ?? 'NULL',
        json['strMeasure2'] as String? ?? 'NULL',
        json['strMeasure3'] as String? ?? 'NULL',
        json['strMeasure4'] as String? ?? 'NULL',
        json['strMeasure5'] as String? ?? 'NULL',
        json['strMeasure6'] as String? ?? 'NULL',
        json['strMeasure7'] as String? ?? 'NULL',
        json['strMeasure8'] as String? ?? 'NULL',
        json['strMeasure9'] as String? ?? 'NULL',
        json['strMeasure10'] as String? ?? 'NULL',
        json['strMeasure11'] as String? ?? 'NULL',
        json['strMeasure12'] as String? ?? 'NULL',
        json['strMeasure13'] as String? ?? 'NULL',
        json['strMeasure14'] as String? ?? 'NULL',
        json['strMeasure15'] as String? ?? 'NULL',
        json['strMeasure16'] as String? ?? 'NULL',
        json['strMeasure17'] as String? ?? 'NULL',
        json['strMeasure18'] as String? ?? 'NULL',
        json['strMeasure19'] as String? ?? 'NULL',
        json['strMeasure20'] as String? ?? 'NULL',
      ],
    );
  }

  factory Recipe.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    return Recipe(
        idMeal: doc.id,
        strMeal: doc['strMeal'] ??  'NULL',
        strMealThumb: doc['strMealThumb'] ?? 'https://source.unsplash.com/random/?food?${DateTime.now().millisecondsSinceEpoch}}',
        strInstructions: doc['strInstructions'] ?? 'NULL',
        strTags: '',
        strYoutube: '',
        ingredients: List<String>.from(doc['ingredients'].map((ing) => ing.toString())),
        measures: [],
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strInstructions': strInstructions,
      'strTags': strTags,
      'strYoutube': strYoutube,
      'ingredients': ingredients,
      'measures': measures,
    };
  }

}
