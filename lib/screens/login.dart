// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../constant/color_font.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _obscurePassword = true; // กำหนดให้รหัสผ่านไม่แสดงเริ่มต้น

  Future sign_in() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/login.php";
    final response = await http.post(Uri.parse(url), body: {
      'email': email.text,
      'password': password.text,
    });

    var data = json.decode(response.body);

    if (data['status'] == "Error") {
      // แสดงข้อความผิดพลาด
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ไม่สามารถเข้าสู่ระบบได้'),
            content: Text(
                'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'), // ข้อความผิดพลาดจาก PHP
            actions: [
              TextButton(
                child: Text('ยืนยัน'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (data['status'] == "success") {
      // print("Name from API: ${data['name']}"); // ตรวจสอบค่าที่ได้จาก API
      String role = data['role']; // รับค่า role จาก API
      if (role == "ผู้ดูแลระบบ" || role == "พนักงาน") {
        // บันทึกชื่อผู้ใช้ลงใน shared_preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email.text);
        await prefs.setString('name', data['name']); // บันทึกค่าชื่อผู้ใช้
        await prefs.setString('role', data['role']); // บันทึกค่าชื่อผู้ใช้
        await prefs.setString('id', data['id']); // บันทึกค่าชื่อผู้ใช้
        await prefs.setString('tel', data['tel']);
        await prefs.setString('email', data['email']);

        // ไปยังหน้า Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HomepageWeb(), // ไม่ต้องส่งชื่อผ่าน constructor
          ),
        );
      } else {
        // แสดงข้อความเมื่อ role ไม่ใช่ admin หรือ staff
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('การเข้าถึงถูกปฏิเสธ'),
              content: Text('ชื่อผู้ใช้งานนี้ไม่มีสิทธิ์ในการเข้าถึงหน้านี้'),
              actions: [
                TextButton(
                  child: Text('ยืนยัน'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future forgetpass() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ลืมรหัสผ่าน?'),
          content: Text('กรุณาติดต่อผู้ดูแลระบบ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: Stack(
        children: [
          Center(
            child: Form(
              key: formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isSmallScreen = constraints.maxWidth < 700;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (!isSmallScreen) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/img/111.png',
                                      width: 300,
                                    ),
                                    Text(
                                      'ระบบแจ้งซ่อม',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'โรงแรมเดอะแคนนาส เชียงใหม่',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                _buildLoginForm(),
                              ],
                            ),
                          ] else ...[
                            Image.asset(
                              'assets/img/111.png',
                              width: 200,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'แอปพลิเคชันระบบแจ้งซ่อม',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'โรงแรมเดอะแคนนาส เชียงใหม่',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLoginForm(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                launchUrl(Uri.parse(
                    "https://drive.google.com/drive/u/0/folders/1-WuvODM8aaS5hyr3GI1rfPPxg5R1faqV"));
              },
              icon: Icon(Icons.download, color: Colors.white),
              label: Text(
                'ดาวน์โหลดแอปพลิเคชัน',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: bottoncolor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// แยกฟอร์มล็อกอินออกมาเป็นฟังก์ชัน
  Widget _buildLoginForm() {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 60,
          child: TextFormField(
            style: const TextStyle(
              fontFamily: Font_.Fonts_T,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.black),
              hintText: "ชื่อผู้ใช้งาน",
              hintStyle: TextStyle(
                color: Colors.black12,
                fontFamily: Font_.Fonts_T,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 251, 252, 244),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน';
              }
              return null;
            },
            controller: email,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          height: 60,
          child: TextFormField(
            style: const TextStyle(
              fontFamily: Font_.Fonts_T,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.key, color: Colors.black),
              hintText: "รหัสผ่าน",
              hintStyle: TextStyle(
                color: Colors.black12,
                fontFamily: Font_.Fonts_T,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 251, 252, 244),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color.fromARGB(255, 164, 164, 164),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return 'กรุณากรอกรหัสผ่าน';
              }
              return null;
            },
            controller: password,
            obscureText: _obscurePassword,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 200),
          child: TextButton(
            onPressed: forgetpass,
            child: Text(
              'ลืมรหัสผ่าน ?',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 140),
          child: SizedBox(
            width: 150,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bottoncolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                bool valid = formKey.currentState!.validate();
                if (valid) {
                  sign_in();
                }
              },
              child: const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
