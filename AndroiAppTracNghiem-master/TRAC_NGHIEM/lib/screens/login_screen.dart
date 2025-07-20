import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'login_help_screen.dart';
import 'teacher_screen.dart';
import '../db/user_database.dart';
import '../utils/user_prefs.dart';
import 'dart:math' as math;


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final AnimationController _appleController;
  late final Animation<Offset> _appleSlideAnimation;
  late final AnimationController _waveController;
  late final AnimationController _tiltController;
  late final AnimationController _faceIdController;
  late final Animation<double> _faceIdFadeAnimation;

  // Khai báo biến ở đầu State:
  bool isBusiness = false;
  final TextEditingController domainController = TextEditingController();

  bool _obscureText = true;

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
    )..repeat(); // Lặp vô hạn

    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _faceIdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _faceIdFadeAnimation = Tween<double>(
      begin: 0.4, // mờ nhất
      end: 1.2,   // đậm nhất
    ).animate(CurvedAnimation(
      parent: _faceIdController,
      curve: Curves.easeInOut,
    ));

  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    _controller.dispose();
    _appleController.dispose();
    _waveController.dispose();
    _tiltController.dispose();
    _faceIdController.dispose();

    super.dispose();
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
                      Image.asset(
                        'assets/images/azota_logo.png',
                        width: 60,
                      ),
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
                                      0, 51, 102, // RGB cho màu #003366
                                    )
                                ],
                                stops: [for (double i = 0; i <= 1; i += 0.1) i],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Text(
                              "Đăng nhập",
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // màu mặc định để lộ Shader
                              ),
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                  const SizedBox(height: 120),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email, số điện thoại hoặc tên tài khoản',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email/tài khoản';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: _obscureText,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text("Business:", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Switch(
                            value: isBusiness,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                isBusiness = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginHelpScreen()),
                          );
                        },
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (isBusiness)
                    TextField(
                      controller: domainController,
                      decoration: InputDecoration(
                        hintText: "Nhập tên miền",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0052CC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              final user = await AppDatabase.getUser(email, password);

                              if (user != null) {
                                await UserPrefs.saveUserData(
                                    user['fullName'],
                                    user['email'],
                                    user['role'],
                                    user['createdAt'] ?? ''
                                );

                                if (user['role'] == 'teacher') {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TeacherScreen()));
                                } else if (user['role'] == 'student') {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
                                );
                              }

                            }
                          },


                          child: const Text("Đăng nhập"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FadeTransition(
                        opacity: _faceIdFadeAnimation,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Yêu cầu đăng nhập"),
                                content: const Text("Bạn cần mở chức năng đăng nhập bằng khuôn mặt sau khi đăng nhập để sử dụng tính năng này."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Đóng dialog
                                    },
                                    child: const Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, 'login_screen.dart');
                                    },
                                    child: const Text("Đăng nhập"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/face_id.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Đăng ký"),
                    ),
                  ),
                  const SizedBox(height: 115),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: RotationTransition(
                        turns: _rotationAnimation,
                        child: Image.asset("assets/images/google_icon.png", width: 24),
                      ),
                      label: const Text("Đăng nhập với Google"),
                      onPressed: () {
                        // xử lý đăng nhập
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
                  const SizedBox(height: 15),
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

                              // Góc nghiêng riêng cho mỗi ký tự, lệch pha theo index
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
}
