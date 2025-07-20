import 'package:flutter/material.dart';
import 'settings_profile/notification_screen.dart';
import 'profile_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = true;
    final String username = "Lê Quốc Đại"; // thay bằng dữ liệu người dùng

    // Dữ liệu hiện đang trống
    final List<Map<String, dynamic>> incompleteExams = [];
    final List<Map<String, dynamic>> incompleteAssignments = [];
    final List<Map<String, dynamic>> recentHistory = [];

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
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // 👉 Nếu đăng nhập thì chuyển sang màn tài khoản
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                } else {
                  // 👉 Nếu chưa đăng nhập, có thể chuyển đến trang đăng nhập nếu cần
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: isLoggedIn
                    ? Text(
                  username.split(' ').last.characters.first.toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                )
                    : const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),

        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: "Đề thi chưa hoàn thành"),
          if (incompleteExams.isEmpty)
            const EmptyMessage(message: "Hiện chưa có đề thi nào."),
          const SizedBox(height: 24),

          const SectionTitle(title: "Bài tập chưa hoàn thành"),
          if (incompleteAssignments.isEmpty)
            const EmptyMessage(message: "Bạn chưa có bài tập nào cần làm."),
          const SizedBox(height: 24),

          const SectionTitle(title: "Lịch sử làm bài / Nộp bài"),
          if (recentHistory.isEmpty)
            const EmptyMessage(message: "Chưa có lịch sử làm bài."),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0052CC),
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.qr_code),
      ),
    );
  }
}

// Widget: Tiêu đề mục
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.8),
    );
  }
}

// Widget: Thông báo khi không có dữ liệu
class EmptyMessage extends StatelessWidget {
  final String message;
  const EmptyMessage({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
