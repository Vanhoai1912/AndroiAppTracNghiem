import 'package:flutter/material.dart';

class FaceIDLoginScreen extends StatefulWidget {
  const FaceIDLoginScreen({super.key});

  @override
  State<FaceIDLoginScreen> createState() => _FaceIDLoginScreenState();
}

class _FaceIDLoginScreenState extends State<FaceIDLoginScreen> {
  bool _isFaceIDEnabled = false;

  void _toggleFaceID(bool value) {
    setState(() {
      _isFaceIDEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Đã bật đăng nhập bằng khuôn mặt' : 'Đã tắt đăng nhập bằng khuôn mặt',
        ),
      ),
    );

    // TODO: Lưu trạng thái vào SharedPreferences hoặc DB nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập bằng khuôn mặt"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.face_outlined, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Đăng nhập bằng khuôn mặt",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Switch(
                value: _isFaceIDEnabled,
                onChanged: _toggleFaceID,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
