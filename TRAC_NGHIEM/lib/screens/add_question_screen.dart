  import 'package:flutter/material.dart';
  import '../services/api_service.dart';
  import 'settings_profile/notification_screen.dart';
  import 'profile_screen.dart';
  import 'teacher_screen.dart';
  import 'create_exam_screen.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;

  class QuestionModel {
    final int id;
    final String question;
    final String optionA;
    final String optionB;
    final String optionC;
    final String optionD;
    final String correctAnswer;

    QuestionModel({
      required this.id,
      required this.question,
      required this.optionA,
      required this.optionB,
      required this.optionC,
      required this.optionD,
      required this.correctAnswer,
    });
  }

  class AddQuestionScreen extends StatefulWidget {
    final int examId;
    final String examName;
    final bool isEditing;

    const AddQuestionScreen({
      super.key,
      required this.examId,
      required this.examName,
      this.isEditing = false,
    });


    @override
    State<AddQuestionScreen> createState() => _AddQuestionScreenState();
  }

  class _AddQuestionScreenState extends State<AddQuestionScreen> {
    final _formKey = GlobalKey<FormState>();
    final _questionController = TextEditingController();
    final _optionAController = TextEditingController();
    final _optionBController = TextEditingController();
    final _optionCController = TextEditingController();
    final _optionDController = TextEditingController();
    final _bulkPasteController = TextEditingController();
    String? _correctAnswer = 'A';
    List<QuestionModel> _questions = [];
    int? _editingQuestionId;

    final bool isLoggedIn = true;
    final String username = "Lê Quốc Đại";

    @override
    void initState() {
      super.initState();
      _loadQuestionsFromApi();
    }

    Future<void> _loadQuestionsFromApi() async {
      final questions = await ApiService.getQuestionsByExamId(widget.examId);
      List<QuestionModel> loadedQuestions = [];

      for (var q in questions) {
        final answers = await ApiService.getAnswersByQuestionId(q['id']);
        final answerMap = {
          for (var a in answers) a['answerLabel']: a['answerText']
        };
        final correct = answers.firstWhere((a) => a['isCorrect'] == true)['answerLabel'];

        loadedQuestions.add(
          QuestionModel(
            id: q['id'],
            question: q['questionText'],
            optionA: answerMap['A'] ?? '',
            optionB: answerMap['B'] ?? '',
            optionC: answerMap['C'] ?? '',
            optionD: answerMap['D'] ?? '',
            correctAnswer: correct,
          ),
        );
      }

      setState(() {
        _questions = loadedQuestions;
      });
    }

    Future<void> bulkAddQuestions(List<QuestionModel> questions) async {
      for (var q in questions) {
        await _addOrUpdateQuestionFromBulk(q);
      }

      // ✅ Load lại danh sách sau khi thêm xong
      await _loadQuestionsFromApi();

      // ✅ Hiện thông báo thành công (nếu muốn)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm ${questions.length} câu hỏi từ Excel')),
      );
    }


    void _editQuestion(QuestionModel question) {
      setState(() {
        _editingQuestionId = question.id;
        _questionController.text = question.question;
        _optionAController.text = question.optionA;
        _optionBController.text = question.optionB;
        _optionCController.text = question.optionC;
        _optionDController.text = question.optionD;
        _correctAnswer = question.correctAnswer;
      });
    }

    void _addOrUpdateQuestion() async {
      if (_formKey.currentState!.validate()) {
        final questionText = _questionController.text;
        final answers = {
          'A': _optionAController.text,
          'B': _optionBController.text,
          'C': _optionCController.text,
          'D': _optionDController.text,
        };
        final correct = _correctAnswer ?? 'A';

        if (_editingQuestionId != null) {
          await ApiService.updateQuestion(
            questionId: _editingQuestionId!,
            questionText: questionText,
            answers: answers,
            correctAnswer: correct,
          );

          final index = _questions.indexWhere((q) => q.id == _editingQuestionId);
          setState(() {
            _questions[index] = QuestionModel(
              id: _editingQuestionId!,
              question: questionText,
              optionA: answers['A']!,
              optionB: answers['B']!,
              optionC: answers['C']!,
              optionD: answers['D']!,
              correctAnswer: correct,
            );
            _editingQuestionId = null;
            _questionController.clear();
            _optionAController.clear();
            _optionBController.clear();
            _optionCController.clear();
            _optionDController.clear();
            _correctAnswer = 'A';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Đã cập nhật câu hỏi'),
                ],
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            ),

          );
        } else {
          final questionId = await ApiService.insertQuestionWithAnswers(
            examId: widget.examId,
            questionText: questionText,
            answers: answers,
            correctAnswer: correct,


          );
          await _loadQuestionsFromApi();

          setState(() {
            _questions.add(QuestionModel(
              id: questionId,
              question: questionText,
              optionA: answers['A']!,
              optionB: answers['B']!,
              optionC: answers['C']!,
              optionD: answers['D']!,
              correctAnswer: correct,
            ));
            _questionController.clear();
            _optionAController.clear();
            _optionBController.clear();
            _optionCController.clear();
            _optionDController.clear();
            _correctAnswer = 'A';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Đã lưu câu hỏi vào database'),
                ],
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              elevation: 6,
            ),

          );
        }
      }
    }

    void _confirmDeleteQuestion(QuestionModel question) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Xác nhận xoá"),
          content: const Text("Bạn có chắc muốn xoá câu hỏi này không?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Huỷ")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xoá", style: TextStyle(color: Colors.red))),
          ],
        ),
      );

      if (confirmed == true) {
        await ApiService.deleteQuestion(question.id);
        setState(() {
          _questions.removeWhere((q) => q.id == question.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 10),
                const Text(
                  "Đã xoá câu hỏi",
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );

      }
    }

    void _parseAndAddStructuredQuestions() async {
      print("🟢 Bắt đầu xử lý thêm nhiều câu hỏi");

      final text = _bulkPasteController.text.trim();
      print("📥 Văn bản được nhập:\n$text");

      final lines = text.split('\n').map((e) => e.trim()).toList();
      List<QuestionModel> newQuestions = [];
      List<String> buffer = [];

      for (String line in lines) {
        if (line.isEmpty) continue;

        buffer.add(line);

        if (line.toUpperCase().startsWith('ANSWER:') && buffer.length >= 6) {
          final questionLine = buffer[0];
          final optionA = buffer[1].replaceFirst(RegExp(r'^A\\.\\s*'), '');
          final optionB = buffer[2].replaceFirst(RegExp(r'^B\\.\\s*'), '');
          final optionC = buffer[3].replaceFirst(RegExp(r'^C\\.\\s*'), '');
          final optionD = buffer[4].replaceFirst(RegExp(r'^D\\.\\s*'), '');
          final correctAnswer = buffer[5].split(':').last.trim().toUpperCase();
          final questionText = questionLine.replaceFirst(RegExp(r'^\\d+\\.\\s*'), '');

          final question = QuestionModel(
            id: 0,
            question: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer,
          );

          newQuestions.add(question);
          print("✅ Đã phân tích: ${question.question} | Đáp án đúng: ${question.correctAnswer}");

          buffer.clear();
        }
      }

      /// 🛠️ Sử dụng Future.wait để đợi tất cả thêm xong
      List<QuestionModel> addedQuestions = [];

      for (var q in newQuestions) {
        final id = await ApiService.insertQuestionWithAnswers(
          examId: widget.examId,
          questionText: q.question,
          answers: {
            'A': q.optionA,
            'B': q.optionB,
            'C': q.optionC,
            'D': q.optionD,
          },
          correctAnswer: q.correctAnswer,
        );
        addedQuestions.add(QuestionModel(
          id: id,
          question: q.question,
          optionA: q.optionA,
          optionB: q.optionB,
          optionC: q.optionC,
          optionD: q.optionD,
          correctAnswer: q.correctAnswer,
        ));
      }

      /// 🟢 Cập nhật danh sách câu hỏi 1 lần duy nhất
      setState(() {
        _questions.addAll(addedQuestions);
        _bulkPasteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade50,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Đã thêm ${addedQuestions.length} câu hỏi từ văn bản",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        ),
      );
    }



    Future<void> _addOrUpdateQuestionFromBulk(QuestionModel q) async {
      final answers = {
        'A': q.optionA,
        'B': q.optionB,
        'C': q.optionC,
        'D': q.optionD,
      };

      // ❗ Trả về int trực tiếp
      final id = await ApiService.insertQuestionWithAnswers(
        examId: widget.examId,
        questionText: q.question,
        answers: answers,
        correctAnswer: q.correctAnswer,
      );

      // ✅ Không xử lý id như map nữa, vì nó là int
      setState(() {
        _questions.add(QuestionModel(
          id: id, // ← dùng trực tiếp int
          question: q.question,
          optionA: q.optionA,
          optionB: q.optionB,
          optionC: q.optionC,
          optionD: q.optionD,
          correctAnswer: q.correctAnswer,
        ));
      });
    }


    void _finishExam() {
      const message = 'Bài thi đã được lưu thành công!';

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherScreen(),
          settings: const RouteSettings(arguments: message),
        ),
            (route) => false,
      );
    }



    Widget _buildAnswerField(String label, TextEditingController controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Đáp án $label", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            decoration: const InputDecoration(
              hintText: "Nhập đáp án...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    Widget _buildRadioOption(String value) {
      return Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _correctAnswer,
            onChanged: (val) => setState(() => _correctAnswer = val),
          ),
          Text("Đáp án $value"),
        ],
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.isEditing ? 'Sửa bài thi' : 'Tạo bài thi',
            style: const TextStyle(color: Color(0xff003366), fontWeight: FontWeight.bold),
          ),


          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset("assets/images/vn_flag.png", width: 28, height: 25),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  if (isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Text(username.split(' ').last.characters.first.toUpperCase(), style: const TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text("Nội dung câu hỏi", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _questionController,
                  validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Nhập câu hỏi...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnswerField("A", _optionAController),
                _buildAnswerField("B", _optionBController),
                _buildAnswerField("C", _optionCController),
                _buildAnswerField("D", _optionDController),
                const SizedBox(height: 16),
                const Text("Chọn đáp án đúng", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildRadioOption("A"),
                _buildRadioOption("B"),
                _buildRadioOption("C"),
                _buildRadioOption("D"),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addOrUpdateQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0052cc),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _editingQuestionId != null ? Icons.save : Icons.add,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_editingQuestionId != null ? "Lưu câu hỏi" : "Thêm câu hỏi"),
                    ],
                  ),

                ),

                const Divider(height: 30),
                Row(
                  children: const [
                    Icon(Icons.content_paste, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Dán nhiều câu hỏi theo định dạng chuẩn",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                TextFormField(
                  controller: _bulkPasteController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: "1. Câu hỏi?\nA. Đáp án A\nB. Đáp án B\nC. Đáp án C\nD. Đáp án D\nĐáp án đúng: A",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _parseAndAddStructuredQuestions();
                    } else {
                      print("Form chưa hợp lệ");
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  icon: const Icon(Icons.playlist_add),
                  label: const Text("Thêm nhiều câu"),
                ),

                const Divider(height: 30),
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Danh sách câu hỏi đã thêm (${_questions.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),


                ..._questions.map((q) => ListTile(
                  title: Text(q.question),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('A. ${q.optionA}'),
                      Text('B. ${q.optionB}'),
                      Text('C. ${q.optionC}'),
                      Text('D. ${q.optionD}'),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                            ),
                            const WidgetSpan(child: SizedBox(width: 6)),
                            TextSpan(
                              text: 'Đáp án đúng: ${q.correctAnswer}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _editQuestion(q),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.orange, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDeleteQuestion(q),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                )),

                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _finishExam,
                    icon: const Icon(Icons.task_alt_rounded, size: 24),
                    label: const Text(
                      "Hoàn tất tạo bài thi",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.greenAccent,
                    ),
                  ),
                )


              ],
            ),
          ),
        ),
      );
    }
  }
