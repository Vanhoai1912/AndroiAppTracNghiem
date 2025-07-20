import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import '../db/user_database.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedRole = 'student'; // Mặc định Học sinh

  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final AnimationController _appleController;
  late final Animation<Offset> _appleSlideAnimation;
  late final AnimationController _waveController;
  late final AnimationController _tiltController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _appleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _appleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _appleController,
      curve: Curves.easeInOut,
    ));

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    _controller.dispose();
    _appleController.dispose();
    _waveController.dispose();
    _tiltController.dispose();

    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AppDatabase.insertUser(
          fullNameController.text.trim(),
          emailController.text.trim(),
          passwordController.text.trim(),
          _selectedRole,
          DateTime.now().toIso8601String(), // thêm thời gian tạo
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Column(
                    children: [
                      Image.asset('assets/images/azota_logo.png', width: 60),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  for (double i = 0; i <= 1; i += 0.1)
                                    Color.fromARGB(
                                      ((0.5 + 0.5 *
                                          (math.sin((- _waveController.value * 2 * math.pi) + i * 10))
                                      ) * 255).toInt(),
                                      0, 51, 102,
                                    )
                                ],
                                stops: [for (double i = 0; i <= 1; i += 0.1) i],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Text(
                              "Đăng ký",
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: fullNameController,
                    decoration: _buildInputDecoration('Họ tên'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: _buildInputDecoration('Email hoặc số điện thoại'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                      if (!value.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Nhập mật khẩu'),
                    validator: (value) =>
                    value != null && value.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Nhập lại mật khẩu'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (value != passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chọn vai trò:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'student',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const Text("Học sinh"),
                          const SizedBox(width: 160), // Khoảng cách giữa 2 radio
                          Radio<String>(
                            value: 'teacher',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const Text("Giáo viên"),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0052CC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Đăng ký"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text("Đăng nhập"),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: RotationTransition(
                        turns: _rotationAnimation,
                        child: Image.asset("assets/images/google_icon.png", width: 24),
                      ),
                      label: const Text("Đăng nhập với Google"),
                      onPressed: () async {
                        const url = 'https://vn.search.yahoo.com/search?fr=mcafee&type=E211VN885G0&p=azota';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Không thể mở URL: $url';
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: SlideTransition(
                        position: _appleSlideAnimation,
                        child: const Icon(Icons.apple, size: 24, color: Colors.white),
                      ),
                      label: const Text("Đăng nhập với Apple"),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _tiltController,
                        builder: (context, child) {
                          final text = "student-mobile-web.tracnghiem.vn";
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(text.length, (index) {
                              final char = text[index];
                              final angle = 0.1 * math.sin(_tiltController.value * 2 * math.pi + index * 0.3);
                              return Transform.rotate(
                                angle: angle,
                                child: Text(
                                  char,
                                  style: const TextStyle(
                                    color: Color(0xff0033CC),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Image.asset("assets/images/vn_flag.png", width: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
