// import 'package:flutter/material.dart';
// import '../db/user_database.dart';
//
// class ReviewScreen extends StatefulWidget {
//   final int resultId;
//   final bool showScore;
//
//   const ReviewScreen({
//     required this.resultId,
//     required this.showScore,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<ReviewScreen> createState() => _ReviewScreenState();
// }
//
// class _ReviewScreenState extends State<ReviewScreen> {
//   late Future<List<QuestionReview>> _reviewFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _reviewFuture = _loadReviewData();
//   }
//
//   Future<List<QuestionReview>> _loadReviewData() async {
//     final db = await AppDatabase.database;
//
//     // Lấy examId từ resultId
//     final results = await db.query(
//       'exam_results',
//       columns: ['examId'],
//       where: 'id = ?',
//       whereArgs: [widget.resultId],
//     );
//     if (results.isEmpty) {
//       throw Exception('Không tìm thấy kết quả bài thi.');
//     }
//     final examId = results.first['examId'] as int;
//
//     // Lấy danh sách câu hỏi của bài thi
//     final questions = await AppDatabase.getQuestionsByExamId(examId);
//
//     // Lấy các câu trả lời đã chọn của học sinh cho lần làm bài này
//     final chosenAnswers = await db.query(
//       'AnswerChoices',
//       where: 'resultId = ?',
//       whereArgs: [widget.resultId],
//     );
//
//     // Tạo một map để tra cứu nhanh câu trả lời đã chọn theo questionId
//     final Map<int, int> selectedAnswerMap = {
//       for (var choice in chosenAnswers)
//         choice['questionId'] as int: choice['answerId'] as int
//     };
//
//     // Xây dựng danh sách câu hỏi để xem lại
//     List<QuestionReview> reviewList = [];
//     for (var questionData in questions) {
//       final questionId = questionData['id'] as int;
//       final answerOptions = await AppDatabase.getAnswersByQuestionId(questionId);
//
//       reviewList.add(
//           QuestionReview(
//             questionId: questionId,
//             questionText: questionData['questionText'] as String,
//             answers: answerOptions.map((answer) => AnswerOption(
//               id: answer['id'] as int,
//               label: answer['answerLabel'] as String,
//               text: answer['answerText'] as String,
//               isCorrect: (answer['isCorrect'] as int) == 1,
//             )).toList(),
//             selectedAnswerId: selectedAnswerMap[questionId],
//           )
//       );
//     }
//     return reviewList;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Xem lại bài làm'),
//         backgroundColor: const Color(0xff0052CC),
//       ),
//       body: FutureBuilder<List<QuestionReview>>(
//         future: _reviewFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Không có dữ liệu để xem lại.'));
//           }
//
//           final reviewList = snapshot.data!;
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: reviewList.length,
//             separatorBuilder: (_, __) => const Divider(height: 32, thickness: 1),
//             itemBuilder: (context, index) {
//               return _buildQuestionTile(reviewList[index], index + 1);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   // === WIDGET ĐÃ SỬA LOGIC TÔ MÀU ===
//   Widget _buildQuestionTile(QuestionReview question, int questionNumber) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Câu $questionNumber: ${question.questionText}',
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//         ),
//         const SizedBox(height: 12),
//         ...question.answers.map((option) {
//           Color? backgroundColor;
//           Widget? trailingIcon;
//
//           // Chỉ tô màu và hiển thị icon khi showScore = 1
//           if (widget.showScore) {
//             final isCorrect = option.isCorrect;
//             final isSelected = option.id == question.selectedAnswerId;
//
//             if (isCorrect) {
//               // Tô màu xanh cho đáp án đúng của đề
//               backgroundColor = Colors.green.shade100;
//               trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
//             } else if (isSelected) {
//               // Nếu đáp án này không đúng mà lại được chọn -> tô màu đỏ
//               backgroundColor = Colors.red.shade100;
//               trailingIcon = const Icon(Icons.cancel, color: Colors.red);
//             }
//           }
//
//           return Container(
//             margin: const EdgeInsets.symmetric(vertical: 4),
//             decoration: BoxDecoration(
//                 color: backgroundColor, // Sẽ là null (không màu) nếu showScore = 0
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300)
//             ),
//             child: ListTile(
//               leading: Radio<int>(
//                 value: option.id,
//                 groupValue: question.selectedAnswerId, // Luôn hiển thị lựa chọn của HS
//                 onChanged: null, // Vô hiệu hóa tương tác
//               ),
//               title: Text(option.text),
//               trailing: trailingIcon, // Sẽ là null nếu showScore = 0
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }
// }
//
// // Model để tổ chức dữ liệu, không thay đổi
// class QuestionReview {
//   final int questionId;
//   final String questionText;
//   final List<AnswerOption> answers;
//   final int? selectedAnswerId;
//
//   QuestionReview({
//     required this.questionId,
//     required this.questionText,
//     required this.answers,
//     this.selectedAnswerId,
//   });
// }
//
// class AnswerOption {
//   final int id;
//   final String label;
//   final String text;
//   final bool isCorrect;
//   AnswerOption({
//     required this.id,
//     required this.label,
//     required this.text,
//     required this.isCorrect,
//   });
// }