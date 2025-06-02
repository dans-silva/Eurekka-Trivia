import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurekka_trivia/models/question.dart';

class TriviaService {
  static Future<List<Question>> fetchQuestions(int categoryId) async {
    final response = await http.get(
      Uri.parse(
          'https://opentdb.com/api.php?amount=10&category=$categoryId&difficulty=medium&type=multiple'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((json) => Question.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
