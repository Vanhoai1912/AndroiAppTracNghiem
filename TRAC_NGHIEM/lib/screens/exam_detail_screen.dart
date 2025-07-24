// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../db/user_database.dart';
// import 'quiz_screen.dart';
// import 'review_screen.dart';
//
// class ExamDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> exam;
//   final int userId;
//   final String username;
//
//   const ExamDetailScreen({
//     required this.exam,
//     required this.userId,
//     required this.username,
//     super.key,
//   });
//
//   @override
//   State<ExamDetailScreen> createState() => _ExamDetailScreenState();
// }
//
// class _ExamDetailScreenState extends State<ExamDetailScreen> {
//   List<Map<String, dynamic>> attemptHistory = [];
//   bool isLoadingHistory = true;
//   bool isLoadingQuestions = false;
//
//   int get userAttempts => attemptHistory.length;
//   int get maxAttempts => widget.exam['attempts'] as int? ?? 1;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttemptHistory();
//   }
//
//   // === HÀM ĐÃ SỬA LẠI LOGIC TÍNH TOÁN ===
//   DateTime? _getDerivedStartTime(Map<String, dynamic> exam) {
//     final createdAtString = exam['createdAt'] as String?;
//     // Lấy giờ từ cột 'startTime' thay vì 'deadline'
//     final startTimeString = exam['startTime'] as String?;
//
//     if (createdAtString == null || startTimeString == null || startTimeString.isEmpty) {
//       return null;
//     }
//
//     try {
//       final createdDate = DateTime.parse(createdAtString);
//       // Tách chuỗi giờ:phút, ví dụ: "19:00" -> ["19", "00"]
//       final timeParts = startTimeString.split(':');
//       if (timeParts.length < 2) return null; // Định dạng giờ không hợp lệ
//
//       final hour = int.parse(timeParts[0]);
//       final minute = int.parse(timeParts[1]);
//
//       // Kết hợp ngày từ createdAt và giờ từ startTime
//       return DateTime(
//         createdDate.year,
//         createdDate.month,
//         createdDate.day,
//         hour,
//         minute,
//       );
//     } catch (e) {
//       print("Lỗi khi phân tích ngày giờ: $e");
//       return null;
//     }
//   }
//
//   Future<void> _loadAttemptHistory() async {
//     final history = await AppDatabase.getUserExamAttempts(widget.userId, widget.exam['id'] as int);
//     if (mounted) {
//       setState(() {
//         attemptHistory = history;
//         isLoadingHistory = false;
//       });
//     }
//   }
//
//   Future<void> _startQuiz() async {
//     setState(() => isLoadingQuestions = true);
//     final examId = widget.exam['id'] as int;
//
//     final rawQuestions = await AppDatabase.getQuestionsByExamId(examId);
//     final List<Map<String, dynamic>> questionsWithAnswers = [];
//     for (var q in rawQuestions) {
//       final questionCopy = Map<String, dynamic>.from(q);
//       final answers = await AppDatabase.getAnswersByQuestionId(q['id'] as int);
//       questionCopy['answers'] = answers;
//       questionsWithAnswers.add(questionCopy);
//     }
//
//     if (!mounted) return;
//     setState(() => isLoadingQuestions = false);
//
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuizScreen(
//           examId: examId,
//           examTitle: widget.exam['title'] as String? ?? 'Không có tiêu đề',
//           studentName: widget.username,
//           questions: questionsWithAnswers,
//           duration: widget.exam['duration'] as int? ?? 0,
//           userId: widget.userId,
//           onSubmit: _loadAttemptHistory,
//         ),
//       ),
//     );
//   }
//
//   String _formatDateTime(String? dtStr) {
//     if (dtStr == null || dtStr.isEmpty) return 'Không có';
//     try {
//       final dt = DateTime.parse(dtStr);
//       return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
//     } catch (_) {
//       return dtStr;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final exam = widget.exam;
//
//     // Logic kiểm tra điều kiện giờ đây sẽ chạy đúng
//     final startTime = _getDerivedStartTime(exam);
//     final bool hasStarted = startTime != null ? DateTime.now().isAfter(startTime) : true;
//
//     final deadlineString = exam['deadline'] as String?;
//     final deadline = deadlineString != null ? DateTime.tryParse(deadlineString) : null;
//     final bool isExpired = deadline != null ? DateTime.now().isAfter(deadline) : false;
//
//     final bool hasAttemptsLeft = userAttempts < maxAttempts;
//
//     final bool canAttempt = hasAttemptsLeft && !isExpired && hasStarted;
//     String buttonLabel;
//
//     if (!hasStarted) {
//       buttonLabel = 'Chưa đến giờ làm bài';
//     } else if (isExpired) {
//       buttonLabel = 'Đã hết hạn';
//     } else if (!hasAttemptsLeft) {
//       buttonLabel = 'Hết lượt làm bài';
//     } else {
//       buttonLabel = 'Làm bài';
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chi tiết bài thi'),
//         backgroundColor: const Color(0xff0052CC),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Text(
//               exam['title'] ?? 'Không có tiêu đề',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             InfoRow(icon: Icons.play_circle_outline, text: "Bắt đầu lúc: ${_formatDateTime(startTime?.toIso8601String())}"),
//             InfoRow(icon: Icons.calendar_today_outlined, text: "Hạn nộp: ${_formatDateTime(exam['deadline'] as String?)}"),
//             InfoRow(icon: Icons.timer_outlined, text: "Thời gian làm bài: ${exam['duration']} phút"),
//             InfoRow(icon: Icons.help_outline, text: "Số câu hỏi: ${exam['questionCount'] ?? 0}"),
//             InfoRow(icon: Icons.repeat, text: "Số lần đã làm: $userAttempts / $maxAttempts"),
//             const SizedBox(height: 24),
//
//             if (isLoadingQuestions)
//               const Center(child: CircularProgressIndicator())
//             else
//               ElevatedButton.icon(
//                 onPressed: canAttempt ? _startQuiz : null,
//                 icon: const Icon(Icons.play_arrow),
//                 label: Text(buttonLabel),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: canAttempt ? const Color(0xff0052CC) : Colors.grey,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//
//             const SizedBox(height: 24),
//             const Text(
//               'Lịch sử làm bài',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(height: 16),
//             if (isLoadingHistory)
//               const Center(child: CircularProgressIndicator())
//             else if (attemptHistory.isEmpty)
//               const Text('Bạn chưa làm bài này lần nào.')
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: attemptHistory.length,
//                 itemBuilder: (context, index) {
//                   final historyItem = attemptHistory[index];
//                   final bool showScore = (exam['showScore'] as int? ?? 0) == 1;
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     child: ListTile(
//                       leading: CircleAvatar(child: Text('${index + 1}')),
//                       title: Text(showScore ? 'Điểm: ${historyItem['score']}' : 'Đã nộp bài'),
//                       subtitle: Text('Lúc: ${_formatDateTime(historyItem['submittedAt'] as String?)}'),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ReviewScreen(
//                               resultId: historyItem['id'] as int,
//                               showScore: showScore,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Widget phụ để hiển thị thông tin cho gọn
// class InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String text;
//
//   const InfoRow({required this.icon, required this.text, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey.shade600, size: 20),
//           const SizedBox(width: 12),
//           Text(text, style: const TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }
// }