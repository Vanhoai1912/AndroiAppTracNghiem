import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/user_prefs.dart';
import 'settings_profile/notification_screen.dart';
import 'login_screen.dart';
import 'settings_profile/change_password_screen.dart';
import 'settings_profile/measurement_unit_screen.dart';
import 'settings_profile/faceid_login_screen.dart';
import 'settings_profile/delete_account_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullName = '';
  String? username = '';
  File? selectedImage;


  DateTime? selectedDate;
  int? gender = 1; // 0: Nam, 1: Nữ
  TextEditingController phoneController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await UserPrefs.getFullName();
    final user = await UserPrefs.getUsername();

    setState(() {
      fullName = name ?? 'Chưa có tên';
      username = user ?? 'username';

      fullNameController.text = fullName!;
      emailController.text = user ?? 'username';
    });
  }

  Future<void> _pickImage() async {
    final permission = await Permission.photos.request(); // iOS
    final storagePermission = await Permission.storage.request(); // Android

    if (permission.isGranted || storagePermission.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chọn ảnh thành công")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần cấp quyền truy cập ảnh")),
      );
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Cài đặt tài khoản", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📦 Danh mục cài đặt
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text("Chung"),
                    tileColor: const Color(0xffE0ECFF),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text("Đổi mật khẩu"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: const Text("Đơn vị đo"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MeasurementUnitScreen()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.face_outlined),
                    title: const Text("Đăng nhập bằng khuôn mặt"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FaceIDLoginScreen()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text("Xoá tài khoản"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận đăng xuất"),
                          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Đăng xuất"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await UserPrefs.clearUserData(); // nếu là async
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // 👤 Thông tin người dùng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          (fullName != null && fullName!.isNotEmpty)
                              ? fullName![0].toUpperCase()
                              : "?",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text("Tải lên"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffE8F0FE),
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tải lên file ảnh và kích thước tối đa 5MB",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (selectedImage != null)
                            Image.file(selectedImage!, height: 120),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Họ và tên", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập họ và tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
                  ),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Username", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: username,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // 📅 Ngày sinh
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Ngày sinh", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Ngày sinh",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      // TODO: cập nhật ngày sinh nếu có
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Vui lòng nhập ngày sinh",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),

// 📧 Email
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffE9EDF5),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Click vào đây để đổi email",
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),

// 📱 Số điện thoại
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Số điện thoại", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Nhập số điện thoại...",
                      border: OutlineInputBorder(),
                    ),
                  ),

// 🚻 Giới tính
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Giới tính", style: TextStyle(color: Colors.grey[700])),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Nam"),
                          leading: Radio<int>(
                            value: 0,
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val!;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Nữ"),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

// 🏫 Thông tin trường
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Thông tin trường", style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffE9EDF5),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {}, // TODO: chức năng thêm
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Thêm"),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "*Yêu cầu nhập thông tin trường",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

// 🔘 Nút Cập nhật
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {}, // TODO: xử lý cập nhật
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0052CC), // màu xám nhạt
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cập nhật",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
