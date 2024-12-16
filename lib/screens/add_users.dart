import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({super.key});

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  // Variables for storing user data
  String? username;
  String? role;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  // Function to handle user registration
  Future<void> AddUsers() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/add_users.php";

    final response = await http.post(Uri.parse(url), body: {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'role': roleController.text,
    });

    var data = json.decode(response.body);

    if (data['status'] == "Error") {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text(data['message']),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (data['status'] == "success") {
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Success'),
            content: Text(data['message']),
            actions: [
              TextButton(
                child: Text('OK'),
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

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar
            Expanded(
              flex: 2,
              child: Card(
                child: Sidebar(
                  username: username,
                  role: role,
                  bottonColor: bottoncolor,
                  onLogout: logout,
                ),
              ),
            ),

            // Form Section
            Expanded(
              flex: 8,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เพิ่มผู้ใช้งานใหม่',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 16.0),
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role Field
                            DropdownButtonFormField<String>(
                              value: roleController.text.isNotEmpty
                                  ? roleController.text
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'ตำแหน่ง',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  ['admin', 'technician', 'staff'].map((role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  roleController.text = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกตำแหน่ง';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Name Field
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'ชื่อ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกชื่อ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Email Field
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'อีเมล',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกอีเมล';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Password Field
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'รหัสผ่าน',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรหัสผ่าน';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Submit Button
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    AddUsers();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  backgroundColor: bottoncolor,
                                ),
                                child: const Text(
                                  'บันทึกผู้ใช้',
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logout Function
  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }
}
