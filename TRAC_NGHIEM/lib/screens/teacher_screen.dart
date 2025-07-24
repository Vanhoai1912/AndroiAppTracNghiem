import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_profile/notification_screen.dart';
import 'create_exam_screen.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String username = "";
  List<Map<String, dynamic>> _exams = [];
  bool _snackShown = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadExams();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Giáo viên";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_snackShown) {
      final message = ModalRoute.of(context)?.settings.arguments as String?;
      if (message != null && message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 3),
            ),
          );
        });
        _snackShown = true;
      }
    }
  }

  Future<void> _loadExams() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print("Không tìm thấy userId trong SharedPreferences.");
      return;
    }

    try {
      final url = Uri.parse('http://172.16.1.243:5162/Teacher/teacher/$userId/exams');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _exams = data.cast<Map<String, dynamic>>();
        });
      } else {
        print("Không thể tải bài thi. Mã lỗi: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Lỗi khi gọi API: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Future<void> _deleteExam(int examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: const Text("Bạn có chắc muốn xoá bài thi này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xoá", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final url = Uri.parse('http://172.16.1.243:5162/Teacher/teacher/exam/$examId');
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          print("Đã xoá bài thi thành công.");
          _loadExams(); // Refresh danh sách
        } else {
          print("Lỗi khi xoá bài thi: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Không thể xoá bài thi. Mã lỗi: ${response.statusCode}")),
          );
        }
      } catch (e) {
        print("Lỗi khi gọi API xoá: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xảy ra lỗi khi xoá bài thi.")),
        );
      }
    }
  }


  void _editExam(Map<String, dynamic> exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateExamScreen(editExam: exam, onSave: _loadExams),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              "assets/images/vn_flag.png",
              width: 28,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  username.split(' ').last.characters.first.toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateExamScreen(onSave: _loadExams),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Tạo bài thi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0052CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._exams.map(
                (exam) => ExamCard(
              exam: exam,
              onDelete: () => _deleteExam(exam['id']),
              onEdit: () => _editExam(exam),
            ),
          ),
        ],
      ),
    );
  }
}

class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExamCard({
    required this.exam,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String _formatDateTime(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';
      try {
        final dateTime = DateTime.parse(dateTimeString);
        return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
      } catch (_) {
        return dateTimeString;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text("Ngày tạo: ${_formatDateTime(exam['createdAt'])}"),
            const SizedBox(height: 10),
            Text("Số câu hỏi: ${exam['questionCount'] ?? 0}"),
            const SizedBox(height: 10),
            Text("Thời gian làm bài: ${exam['duration']} phút"),
            const SizedBox(height: 10),
            Text("Mã bài thi: ${exam['code']}"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final code = exam['code'] ?? 'Không có mã';
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Mã bài thi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                code,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã sao chép mã bài thi')),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Sao chép'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Đóng'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}