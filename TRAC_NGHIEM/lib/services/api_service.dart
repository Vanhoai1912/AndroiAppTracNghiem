import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://172.16.1.243:5162/api'; // URL API ASP.NET Core

  static Future<List<Map<String, dynamic>>> getQuestionsByExamId(int examId) async {
    final response = await http.get(Uri.parse('$baseUrl/questions/by-exam/$examId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load questions');
    }
  }

  static Future<List<Map<String, dynamic>>> getAnswersByQuestionId(int questionId) async {
    final response = await http.get(Uri.parse('$baseUrl/answers/by-question/$questionId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load answers');
    }
  }

  static Future<int> insertQuestionWithAnswers({
    required int examId,
    required String questionText,
    required Map<String, String> answers,
    required String correctAnswer,
  }) async {
    final url = Uri.parse('$baseUrl/questions');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'examId': examId,
        'questionText': questionText, // ✅ chứ không phải 'question'
        'answers': answers,
        'correctAnswer': correctAnswer,
      }),
    );

    print('📥 Phản hồi từ API thêm câu hỏi: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is int) {
        return data; // ✅ đúng với backend hiện tại
      }

// Trường hợp backend trả kiểu map
      if (data is Map<String, dynamic>) {
        if (data.containsKey('questionId')) return data["questionId"];
      }

      throw Exception("❌ Phản hồi không hợp lệ: $data");

      throw Exception("❌ Phản hồi không hợp lệ: $data");
    } else {
      throw Exception("❌ Lỗi khi thêm câu hỏi: ${response.body}");
    }
  }



  static Future<void> updateQuestion({
    required int questionId,
    required String questionText,
    required Map<String, String> answers,
    required String correctAnswer,
  }) async {
    await http.put(
      Uri.parse('$baseUrl/questions/$questionId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'questionText': questionText,
        'answers': answers.entries.map((e) => {
          'answerLabel': e.key,
          'answerText': e.value,
          'isCorrect': e.key == correctAnswer
        }).toList()
      }),
    );
  }

  static Future<void> deleteQuestion(int questionId) async {
    await http.delete(Uri.parse('$baseUrl/questions/$questionId'));
  }
}
