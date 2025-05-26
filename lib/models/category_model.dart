// lib/models/category_model.dart
class CategoryModel {
  final int id;
  final String nomCategorie;
  final String? description;

  CategoryModel({
    required this.id,
    required this.nomCategorie,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nomCategorie: json['nom_categorie'],
      description: json['description'],
    );
  }
}