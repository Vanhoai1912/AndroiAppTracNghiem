import 'package:flutter/material.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/user_prefs.dart';
import '/db/user_database.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {

  final TextEditingController _reasonController = TextEditingController();

  bool _showConfirmButton = false;

  @override
  void initState() {
    super.initState();

    _reasonController.addListener(() {
      setState(() {
        _showConfirmButton = _reasonController.text.trim().isNotEmpty;
      });
    });
  }

  void _handleDeleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");

    if (email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xoá tài khoản"),
        content: const Text("Bạn có chắc chắn muốn xoá tài khoản này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // ✅ Xoá khỏi database
              await AppDatabase.deleteUserByEmail(email);

              // ✅ Xoá local lưu trữ
              await UserPrefs.clearUserData();

              // ✅ Hiện thông báo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tài khoản đã bị xoá")),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text(
              "Xoá",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xoá tài khoản"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xoá tài khoản",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Xác nhận xoá tài khoản. Nhập vào lý do bạn muốn xoá tài khoản và bấm \"Xác nhận\" để xoá tài khoản của bạn.",
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Nhập lý do...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Nút chỉ hiện nếu có nội dung nhập
            if (_showConfirmButton)
              SizedBox(
                width: 120,
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleDeleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0052CC),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Xác nhận"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
