// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import '../db/user_database.dart';
// import '../utils/answer_choice_helper.dart';
//
// class QuizScreen extends StatefulWidget {
//   final int examId;
//   final String examTitle;
//   final String studentName;
//   final List<Map<String, dynamic>> questions;
//   final int duration;
//   final int userId;
//   final VoidCallback onSubmit;
//
//   const QuizScreen({
//     required this.examId,
//     required this.examTitle,
//     required this.studentName,
//     required this.questions,
//     required this.duration,
//     required this.userId,
//     required this.onSubmit,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   // --- Các biến state giữ nguyên ---
//   late Timer _timer;
//   late Duration _remaining;
//   final Map<int, String> _answers = {};
//   final ItemScrollController _itemScrollController = ItemScrollController();
//   final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
//
//   @override
//   void initState() {
//     super.initState();
//     _remaining = Duration(minutes: widget.duration);
//     _startTimer();
//   }
//
//   // --- Các hàm logic giữ nguyên ---
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel(); return;
//       }
//       if (_remaining.inSeconds <= 0) {
//         timer.cancel();
//         _showTimeUpDialog();
//       } else {
//         setState(() => _remaining -= const Duration(seconds: 1));
//       }
//     });
//   }
//
//   void _scrollToQuestion(int index) {
//     _itemScrollController.scrollTo(
//       index: index,
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeInOutCubic,
//     );
//   }
//
//   Future<void> _submitQuiz() async {
//     if (_timer.isActive) _timer.cancel();
//     double score = 0;
//     for (var q in widget.questions) {
//       final qid = q['id'] as int;
//       final correctLabel = (q['answers'] as List<Map<String, dynamic>>)
//           .firstWhere((a) => a['isCorrect'] == 1)['answerLabel'] as String;
//       if (_answers[qid] == correctLabel) score += 1;
//     }
//     final double finalScore =
//     widget.questions.isEmpty ? 0 : (score / widget.questions.length) * 100;
//     final resultId = await AppDatabase.insertExamResult(
//         widget.examId, widget.userId, finalScore, DateTime.now().toIso8601String());
//
//     for (var q in widget.questions) {
//       final qid = q['id'] as int;
//       final selectedLabel = _answers[qid];
//       if (selectedLabel != null) {
//         final selectedAnswer = (q['answers'] as List<Map<String, dynamic>>)
//             .firstWhere((a) => a['answerLabel'] == selectedLabel);
//         final answerId = selectedAnswer['id'] as int;
//         final isCorrect = selectedAnswer['isCorrect'] == 1 ? 1 : 0;
//         await AnswerChoiceHelper.insertAnswerChoice(
//             resultId: resultId,
//             questionId: qid,
//             answerId: answerId,
//             selectedAnswerLabel: selectedLabel,
//             isCorrect: isCorrect);
//       }
//     }
//     widget.onSubmit();
//     if (mounted) Navigator.of(context).pop();
//   }
//
//   Future<void> _showConfirmationDialog() async {
//     return showDialog<void>(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//               title: const Text('Xác nhận nộp bài'),
//               content: SizedBox(
//                   width: double.maxFinite,
//                   child: SingleChildScrollView(
//                       child: ListBody(children: <Widget>[
//                         const Text('Bạn có chắc chắn muốn nộp bài không?'),
//                         const SizedBox(height: 20),
//                         _buildQuestionNavigator(isDialog: true),
//                       ]))),
//               actions: <Widget>[
//                 TextButton(
//                     child: const Text('Hủy'),
//                     onPressed: () => Navigator.of(context).pop()),
//                 FilledButton(
//                     child: const Text('Xác nhận'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       _submitQuiz();
//                     })
//               ]);
//         });
//   }
//
//   Future<void> _showTimeUpDialog() async {
//     if (!mounted || (ModalRoute.of(context)?.isCurrent != true)) return;
//     return showDialog<void>(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//               title: const Text("Hết giờ làm bài!"),
//               content: const Text(
//                   "Thời gian làm bài của bạn đã kết thúc. Bài làm sẽ được tự động nộp."),
//               actions: [
//                 FilledButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       _submitQuiz();
//                     },
//                     child: const Text("Xác nhận"))
//               ]);
//         });
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
//
//   // --- UI Widgets ---
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await _showConfirmationDialog();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F7FA), // Nền xám nhạt
//         appBar: AppBar(
//           title: const Text('Làm bài thi'),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black87,
//           elevation: 1,
//           automaticallyImplyLeading: false,
//         ),
//         body: Column(
//           children: [
//             _buildTopBar(),
//             // Giữ lại khối thông tin bài thi
//             _buildExamInfo(),
//             Expanded(
//               child: _buildQuestionsList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // === WIDGET MỚI: Khối thông tin bài thi được thiết kế lại ===
//   Widget _buildExamInfo() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: const BoxDecoration(
//           color: Color(0xFFE3F2FD), // Nền xanh dương nhạt
//           border: Border(top: BorderSide(color: Colors.black12), bottom: BorderSide(color: Colors.black12))
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.examTitle,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.person, size: 16, color: Colors.grey.shade700),
//                   const SizedBox(width: 6),
//                   Text('Học sinh: ${widget.studentName}', style: const TextStyle(fontSize: 14)),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.list_alt, size: 16, color: Colors.grey.shade700),
//                   const SizedBox(width: 6),
//                   Text('Tổng số câu: ${widget.questions.length}', style: const TextStyle(fontSize: 14)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // === WIDGET MỚI: Thanh thông tin trên cùng ===
//   Widget _buildTopBar() {
//     final bool timeRunningOut = _remaining.inSeconds <= 60 && _remaining.inSeconds > 0;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       color: Colors.white,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Chip(
//                 avatar: Icon(
//                   Icons.timer_outlined,
//                   color: timeRunningOut ? Colors.white : Colors.blueAccent,
//                 ),
//                 label: Text(
//                   _formatDuration(_remaining),
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: timeRunningOut ? Colors.white : Colors.blueAccent),
//                 ),
//                 backgroundColor: timeRunningOut ? Colors.redAccent.withOpacity(0.9) : Colors.blue.shade50,
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.send, size: 20),
//                 label: const Text("Nộp bài"),
//                 onPressed: _showConfirmationDialog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildQuestionNavigator(),
//         ],
//       ),
//     );
//   }
//
//   // === WIDGET MỚI: Điều hướng câu hỏi ===
//   Widget _buildQuestionNavigator({bool isDialog = false}) {
//     if (isDialog) {
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
//         itemCount: widget.questions.length,
//         itemBuilder: (context, index) {
//           final questionId = widget.questions[index]['id'] as int;
//           final isAnswered = _answers.containsKey(questionId);
//           return CircleAvatar(
//               backgroundColor:
//               isAnswered ? Colors.green : Colors.grey.shade300,
//               child: Text('${index + 1}',
//                   style: TextStyle(
//                       color: isAnswered ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.bold)));
//         },
//       );
//     }
//     return SizedBox(
//       height: 42,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.questions.length,
//         itemBuilder: (context, index) {
//           final questionId = widget.questions[index]['id'] as int;
//           final isAnswered = _answers.containsKey(questionId);
//           return GestureDetector(
//             onTap: () => _scrollToQuestion(index),
//             child: Tooltip(
//               message: "Câu ${index + 1}",
//               child: Container(
//                 width: 42,
//                 margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                 decoration: BoxDecoration(
//                   color: isAnswered ? Colors.green.shade100 : Colors.transparent,
//                   border: Border.all(
//                     color: isAnswered ? Colors.green : Colors.grey.shade400,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text('${index + 1}',
//                       style: TextStyle(
//                           color: isAnswered ? Colors.green.shade900 : Colors.black54,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16)),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // === WIDGET MỚI: Danh sách câu hỏi với giao diện mới ===
//   Widget _buildQuestionsList() {
//     return ScrollablePositionedList.builder(
//         padding: const EdgeInsets.all(8),
//         itemCount: widget.questions.length,
//         itemScrollController: _itemScrollController,
//         itemPositionsListener: _itemPositionsListener,
//         itemBuilder: (context, index) {
//           final question = widget.questions[index];
//           return Card(
//               elevation: 2,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text.rich(
//                           TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'Câu ${index + 1}: ',
//                                 style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueAccent),
//                               ),
//                               TextSpan(
//                                 text: question['questionText'] as String,
//                                 style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ..._buildAnswerOptions(question),
//                       ])));
//         });
//   }
//
//   // === WIDGET MỚI: Widget tùy chỉnh cho từng lựa chọn trả lời ===
//   List<Widget> _buildAnswerOptions(Map<String, dynamic> question) {
//     final questionId = question['id'] as int;
//     return (question['answers'] as List<Map<String, dynamic>>).map((answer) {
//       final isSelected = _answers[questionId] == answer['answerLabel'];
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6.0),
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               _answers[questionId] = answer['answerLabel'] as String;
//             });
//           },
//           borderRadius: BorderRadius.circular(10),
//           child: Ink(
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.blue.shade50 : Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
//                 width: isSelected ? 2.0 : 1.0,
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               child: Row(
//                 children: [
//                   Icon(
//                     isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
//                     color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(child: Text(answer['answerText'] as String, style: const TextStyle(fontSize: 16))),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }
//
//   String _formatDuration(Duration d) {
//     final minutes = d.inMinutes.toString().padLeft(2, '0');
//     final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }
// }