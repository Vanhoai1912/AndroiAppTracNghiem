// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../db/user_database.dart';
//
// class ExamResultsScreen extends StatefulWidget {
//   final int examId;
//   final String examTitle;
//
//   const ExamResultsScreen({
//     required this.examId,
//     required this.examTitle,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<ExamResultsScreen> createState() => _ExamResultsScreenState();
// }
//
// class _ExamResultsScreenState extends State<ExamResultsScreen> {
//   late Future<List<Map<String, dynamic>>> _resultsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _resultsFuture = _loadExamResults();
//   }
//
//   Future<List<Map<String, dynamic>>> _loadExamResults() async {
//     // Chúng ta cần một hàm mới trong AppDatabase để lấy kết quả kèm tên học sinh
//     return AppDatabase.getResultsForExam(widget.examId);
//   }
//
//   String _formatDateTime(String? dtStr) {
//     if (dtStr == null || dtStr.isEmpty) return 'N/A';
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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Kết quả: ${widget.examTitle}'),
//         backgroundColor: const Color(0xff0052CC),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _resultsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Lỗi: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Chưa có học sinh nào nộp bài.',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             );
//           }
//
//           final results = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(8.0),
//             itemCount: results.length,
//             itemBuilder: (context, index) {
//               final result = results[index];
//               final studentName = result['fullName'] ?? 'Không rõ';
//               final score = result['score'] as double?;
//               final submittedAt = result['submittedAt'] as String?;
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     child: Text((index + 1).toString()),
//                   ),
//                   title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text('Nộp lúc: ${_formatDateTime(submittedAt)}'),
//                   trailing: Chip(
//                     label: Text(
//                       '${score?.toStringAsFixed(1) ?? 'N/A'} điểm',
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                     backgroundColor: Colors.blueAccent,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }