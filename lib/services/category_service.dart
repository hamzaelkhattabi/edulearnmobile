// lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../utils/api_constants.dart';

class CategoryService {
  Future<List<CategoryModel>> getAllCategories() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.categoriesEndpoint),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => CategoryModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}