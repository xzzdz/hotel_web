import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'home.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  String? username;
  String? role;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedType = 'ไฟฟ้า';
  String _selectedStatus = 'รอดำเนินการ';
  DateTime _selectedDate = DateTime.now();

  List<String> types = ['ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = ['รอดำเนินการ'];

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
    // print("Username: $username, Role: $role");
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      String url =
          "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/add_report.php";

      // สร้างข้อมูลสำหรับส่ง
      Map<String, String> data = {
        'username': username ?? '',
        'date': _selectedDate.toIso8601String(),
        'type': _selectedType,
        'status': _selectedStatus,
        'detail': _detailController.text,
        'location': _locationController.text,
      };

      try {
        // ส่งคำขอแบบ POST
        final response = await http.post(
          Uri.parse(url),
          body: data,
        );

        // ตรวจสอบสถานะการตอบกลับ
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);

          if (responseData['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("บันทึกข้อมูลสำเร็จ!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomepageWeb()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("เกิดข้อผิดพลาด: ${responseData['message']}")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เกิดข้อผิดพลาด: ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์")),
        );
      }
    }
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
            // Main Content
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
                        'เพิ่มรายการแจ้งซ่อม',
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
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'ประเภท',
                                border: OutlineInputBorder(),
                              ),
                              items: types.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'สถานที่',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกสถานที่';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _detailController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'รายละเอียด',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรายละเอียด';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today, // เลือกไอคอนที่ต้องการ
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                const SizedBox(
                                    width:
                                        8), // เพิ่มช่องว่างระหว่างไอคอนกับข้อความ
                                Text(
                                  "วันที่: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    // fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitReport,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  backgroundColor: bottoncolor,
                                ),
                                child: const Text("บันทึกการแจ้งซ่อม",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 18,
                                      color: Colors.white,
                                    )),
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
