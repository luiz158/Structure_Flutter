import 'dart:core';
import 'dart:async';

import 'models/models.dart';
import 'repository.dart';

class MemoryRepository extends Repository {
  final List<Recipe> _currentRecipes = <Recipe>[];
  final List<Ingredient> _currentIngredients = <Ingredient>[];

  Stream<List<Recipe>>? _recipeStream;
  Stream<List<Ingredient>>? _ingredientStream;

  final StreamController _recipeStreamController =
      StreamController<List<Recipe>>();
  final StreamController _ingredientStreamController =
      StreamController<List<Ingredient>>();

  @override
  Future init() {
    return Future.value();
  }

  @override
  void close() {
    _recipeStreamController.close();
    _ingredientStreamController.close();
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return Future.value(_currentIngredients);
  }

  @override
  Future<List<Recipe>> findAllRecipes() {
    return Future.value(_currentRecipes);
  }

  @override
  Future<Recipe> findRecipeById(int id) {
    return Future.value(
        _currentRecipes.firstWhere((recipe) => recipe.id == id));
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) {
    final recipe =
        _currentRecipes.firstWhere((recipe) => recipe.id == recipeId);
    return Future.value(_currentIngredients
        .where((ingredient) => ingredient.recipeId == recipe.id)
        .toList());
  }

  @override
  Future<int> insertRecipe(Recipe recipe) {
    _currentRecipes.add(recipe);
    _recipeStreamController.sink.add([recipe]);
    if (recipe.ingredients != null) {
      insertIngredients(recipe.ingredients!);
    }
    return Future.value(0);
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    if (ingredients.isNotEmpty) {
      _currentIngredients.addAll(ingredients);
      _ingredientStreamController.sink.add(ingredients);
    }
    return Future.value(<int>[]);
  }

  @override
  Future<void> deleteRecipe(Recipe recipe) async {
    _currentRecipes.remove(recipe);
    if (recipe.id != null) {
      deleteRecipeIngredients(recipe.id!);
    }
  }

  @override
  Future<void> deleteIngredient(Ingredient ingredient) async {
    _currentIngredients.remove(ingredient);
  }

  @override
  Future<void> deleteIngredients(List<Ingredient> ingredients) async {
    _currentIngredients
        .removeWhere((ingredient) => ingredients.contains(ingredient));
  }

  @override
  Future<void> deleteRecipeIngredients(String recipeId) async {
    _currentIngredients
        .removeWhere((ingredient) => ingredient.recipeId == recipeId);
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    _recipeStream ??= _recipeStreamController.stream as Stream<List<Recipe>>;
    return _recipeStream!;
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    _ingredientStream ??=
        _ingredientStreamController.stream as Stream<List<Ingredient>>;
    return _ingredientStream!;
  }
}
