// import '../db/user_database.dart';
// class AnswerChoiceHelper {
//   static Future<List<Map<String, dynamic>>> getChoicesByResult(int resultId) async {
//     final db = await AppDatabase.database;
//     return db.query(
//       'AnswerChoices',
//       where: 'resultId = ?',
//       whereArgs: [resultId],
//     );
//   }
//   /// Lưu lựa chọn từng câu hỏi cho một kết quả bài thi
//   static Future<void> insertAnswerChoice({
//     required int resultId,
//     required int questionId,
//     required int answerId,
//     required String selectedAnswerLabel,
//     required int isCorrect, // 0 hoặc 1
//   }) async {
//     final db = await AppDatabase.database;
//     await db.insert('AnswerChoices', {
//       'resultId': resultId,
//       'questionId': questionId,
//       'answerId': answerId,
//       'selectedAnswerLabel': selectedAnswerLabel,
//       'isCorrect': isCorrect,
//     });
//   }
// }
