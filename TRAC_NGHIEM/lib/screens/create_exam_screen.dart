import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/user_database.dart';
import 'settings_profile/notification_screen.dart';
import 'profile_screen.dart';
import 'add_question_screen.dart';
import 'teacher_screen.dart';
import 'dart:math';

class CreateExamScreen extends StatefulWidget {
  final Map<String, dynamic>? editExam;
  final VoidCallback? onSave;

  const CreateExamScreen({super.key, this.editExam, this.onSave});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final bool isLoggedIn = true;
  final String username = "Lê Quốc Đại";
  final int userId = 1;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _examNameController = TextEditingController();
  String? _selectedSubject;
  String? _selectedClass;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _attemptsController = TextEditingController();
  bool _showScoreImmediately = false;

  final List<String> _subjects = ['Toán', 'Ngữ văn', 'Tiếng Anh', 'Sinh học', 'Vật lý', 'Âm nhạc', 'Mỹ thuật', 'Hóa học', 'Khác'];
  final List<String> _classes = ['Lớp 1', 'Lớp 2', 'Lớp 3', 'Lớp 4', 'Lớp 5', 'Lớp 6', 'Lớp 7', 'Lớp 8', 'Lớp 9', 'Lớp 10', 'Lớp 11', 'Lớp 12', 'Đại học'];

  // Hàm tạo mã ngẫu nhiên
  Future<String> _generateUniqueExamCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code;

    do {
      code = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    } while (await AppDatabase.examCodeExists(code));

    return code;
  }


  @override
  void initState() {
    super.initState();
    if (widget.editExam != null) {
      _examNameController.text = widget.editExam!['title'];
      _selectedSubject = widget.editExam!['subject'];
      _selectedClass = widget.editExam!['grade'];
      _selectedDate = DateTime.tryParse(widget.editExam!['deadline'] ?? '');
      final timeParts = (widget.editExam!['startTime'] ?? '').split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
      _durationController.text = widget.editExam!['duration'].toString();
      _attemptsController.text = widget.editExam!['attempts'].toString();
      _passwordController.text = widget.editExam!['password'] ?? '';
      _showScoreImmediately = widget.editExam!['showScore'] == 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherScreen()));
              },
            ),
            const SizedBox(width: 4),
            Text(
              widget.editExam != null ? 'Chỉnh sửa bài thi' : 'Tạo bài thi',
              style: const TextStyle(color: Color(0xff003366), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset("assets/images/vn_flag.png", width: 28, height: 25, fit: BoxFit.contain),
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
                child: isLoggedIn
                    ? Text(username.split(' ').last.characters.first.toUpperCase(), style: const TextStyle(color: Colors.black))
                    : const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tên bài thi'),
              _buildTextField(_examNameController, 'Nhập tên bài thi'),

              _buildLabel('Môn học'),
              _buildDropdown(_subjects, _selectedSubject, (val) => setState(() => _selectedSubject = val)),

              _buildLabel('Lớp'),
              _buildDropdown(_classes, _selectedClass, (val) => setState(() => _selectedClass = val)),

              _buildLabel('Hạn nộp'),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: _buildDateTimeBox(
                  _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Chọn ngày',
                ),
              ),

              _buildLabel('Giờ bắt đầu'),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _selectedTime = picked);
                },
                child: _buildDateTimeBox(
                  _selectedTime != null ? _selectedTime!.format(context) : 'Chọn giờ',
                ),
              ),

              _buildLabel('Thời lượng (phút)'),
              _buildTextField(_durationController, 'VD: 45'),

              _buildLabel('Số lần làm lại'),
              _buildTextField(_attemptsController, 'VD: 2', isNumber: true),


              _buildLabel('Mật khẩu bài thi'),
              _buildPasswordField(
                _passwordController,
                'Nhập mật khẩu (nếu có)',
                isPassword: true,
              ),


              const SizedBox(height: 8),
              CheckboxListTile(
                value: _showScoreImmediately,
                onChanged: (val) => setState(() => _showScoreImmediately = val ?? false),
                title: const Text("Hiển thị điểm ngay sau khi nộp"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0052cc),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(widget.editExam != null ? 'Cập nhật bài thi' : 'Tạo bài thi', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  if (widget.editExam != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_note),
                        label: const Text("Sửa câu hỏi trong bài thi"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddQuestionScreen(
                                examId: widget.editExam!['id'],
                                examName: widget.editExam!['title'],
                                isEditing: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint,
      {bool isNumber = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 4) {
          return 'Mật khẩu phải từ 4 ký tự trở lên';
        }
        return null;
      },
    );
  }


  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) => TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    validator: (val) => val == null || val.isEmpty ? 'Không được để trống' : null,
  );

  Widget _buildDropdown(List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Hãy chọn một mục' : null,
    );
  }

  Widget _buildDateTimeBox(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade400),
      color: Colors.grey[100],
    ),
    child: Text(text),
  );

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null || _selectedClass == null || _selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
        );
        return;
      }

      final now = DateTime.now();
      if (_selectedDate!.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
        final selectedMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
        final nowMinutes = now.hour * 60 + now.minute;
        if (selectedMinutes <= nowMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Giờ bắt đầu phải sau giờ hiện tại")),
          );
          return;
        }
      }
      final name = _examNameController.text;
      final subject = _selectedSubject!;
      final deadline = _selectedDate!.toIso8601String();
      final startTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      final duration = int.tryParse(_durationController.text) ?? 0;
      final attempts = int.tryParse(_attemptsController.text) ?? 1;
      final showScore = _showScoreImmediately ? 1 : 0;
      final createdAt = DateTime.now().toIso8601String();
      final password = _passwordController.text;

      if (widget.editExam != null) {
        final original = widget.editExam!;
        final hasChanges =
            name != original['title'] ||
                subject != original['subject'] ||
                deadline != original['deadline'] ||
                startTime != original['startTime'] ||
                duration != original['duration'] ||
                attempts != original['attempts'] ||
                showScore != original['showScore'] ||
                password != original['password'] ||
                _selectedClass != original['grade'];



        if (!hasChanges) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text("Không có thay đổi nào để cập nhật.")),
                ],
              ),
              backgroundColor: Color(0xFF64B5F6), // Xanh dương nhạt
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );


          return;
        }
        await AppDatabase.updateExam({
          'id': widget.editExam!['id'],
          'title': name,
          'subject': subject,
          'deadline': deadline,
          'startTime': startTime,
          'duration': duration,
          'attempts': attempts,
          'showScore': showScore,
          'grade': _selectedClass ?? '',
          'password': password,
        });

        widget.onSave?.call();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherScreen(),
            settings: const RouteSettings(arguments: "Cập nhật bài thi thành công"),
          ),
        );

      } else {
        final examCode = await _generateUniqueExamCode();
        final examId = await AppDatabase.insertExam({
          'title': name,
          'subject': subject,
          'deadline': deadline,
          'startTime': startTime,
          'duration': duration,
          'attempts': attempts,
          'showScore': showScore,
          'createdBy': userId,
          'createdAt': createdAt,
          'grade': _selectedClass ?? '',
          'code': examCode,
          'password': password,
      });

        widget.onSave?.call();


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestionScreen(
              examName: name,
              examId: examId,
            ),
          ),
        );
      }
    }
  }
}
