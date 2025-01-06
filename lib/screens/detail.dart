import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class Detail extends StatefulWidget {
  final dynamic item;

  const Detail({Key? key, required this.item}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? currentUserName;
  String? currentStatus;
  String? assignedTo;
  String? username;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    fetchReportDetail();
    _loadUserName();
  }

  Future<void> _loadCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName = prefs.getString('name');
    });
  }

  Future<void> fetchReportDetail() async {
    try {
      String url =
          "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/get_report_detail.php";
      final response = await http.post(
        Uri.parse(url),
        body: {'id': widget.item['id'].toString()},
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = data['report']['status'];
          assignedTo = data['report']['assigned_to'];
          username = data['report']['username']; // ดึงข้อมูล username
        });
      } else {
        _showSnackBar('เกิดข้อผิดพลาด: ${data['message']}');
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Sidebar ฝั่งซ้าย
            Expanded(
              flex: 2,
              child: Sidebar(
                username: username,
                role: role,
                bottonColor: bottoncolor,
                onLogout: logout,
              ),
            ),
            // Main Content ฝั่งขวา
            Expanded(
              flex: 8,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header ด้านบน
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: bottoncolor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const ListTile(
                        leading:
                            Icon(Icons.report, size: 40, color: Colors.white),
                        title: Text(
                          'รายละเอียดการแจ้งซ่อม',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'แสดงข้อมูลการแจ้งซ่อม',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // การ์ดแสดงรายละเอียดแจ้งซ่อม
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListView(
                          children: [
                            _buildDetailItem('รหัสแจ้งซ่อม', widget.item['id']),
                            _buildDetailItem(
                                'ผู้แจ้ง', username ?? '-'), // ใช้ username
                            _buildDetailItem('ประเภท', widget.item['type']),
                            _buildDetailItem(
                                'รายละเอียด', widget.item['detail']),
                            _buildDetailItem('สถานะ', currentStatus ?? '-'),
                            _buildDetailItem('วันที่แจ้ง', widget.item['date']),

                            if (assignedTo != null && assignedTo!.isNotEmpty)
                              _buildDetailItem('ผู้รับงาน', assignedTo ?? '-'),
                            const SizedBox(height: 20),
                            // // ปุ่ม Action
                            // if (currentStatus == "รอดำเนินการ")
                            //   _buildActionButton("รับงาน", "กำลังดำเนินการ"),
                            // if (currentStatus == "กำลังดำเนินการ" &&
                            //     assignedTo == currentUserName)
                            //   _buildActionButton("เสร็จสิ้น", "เสร็จสิ้น"),//////function รับงานและเสร็จสิ้น
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String newStatus) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _updateStatus(newStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: bottoncolor,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      String url =
          "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/update_status.php";
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': widget.item['id'].toString(),
          'status': newStatus,
          'assigned_to':
              currentStatus == "รอดำเนินการ" ? currentUserName : assignedTo,
        },
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = newStatus;
          if (newStatus == "กำลังดำเนินการ") {
            assignedTo = currentUserName;
          }
        });
        _showSnackBar('สถานะถูกอัปเดตเรียบร้อย');
      } else {
        _showSnackBar('เกิดข้อผิดพลาด: ${data['message']}');
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }
}
