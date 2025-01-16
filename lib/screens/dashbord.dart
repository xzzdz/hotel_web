import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class Dashbord extends StatefulWidget {
  const Dashbord({super.key});

  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  String? username;
  String? role;

  Future<List<dynamic>> fetchReports() async {
    const url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Failed to load reports");
    }
  }

  Map<String, int> processDataByType(List<dynamic> reports) {
    Map<String, int> typeCounts = {};
    for (var report in reports) {
      String type = report['type'];
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> processDataByStatus(List<dynamic> reports) {
    Map<String, int> statusCounts = {};
    for (var report in reports) {
      String status = report['status'];
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
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
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Sidebar(
                  username: username,
                  role: role,
                  bottonColor: bottoncolor,
                  onLogout: logout,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 8,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "ไม่มีข้อมูลการแจ้งซ่อม",
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      } else {
                        final reports = snapshot.data!;
                        final typeData = processDataByType(reports);
                        final statusData = processDataByStatus(reports);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("จำนวนการแจ้งซ่อม"),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // เพิ่มข้อความที่คุณต้องการ
                                        const Text(
                                          "ประเภท",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildBarChart(typeData),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 60),
                                        // เพิ่มข้อความที่คุณต้องการ
                                        const Text(
                                          "สถานะ",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildPieChart(statusData),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.primaries[index % Colors.primaries.length],
                  width: 24,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // กำหนด interval เป็น 1 เพื่อให้แสดงเฉพาะจำนวนเต็ม
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final keys = data.keys.toList();
                  if (value.toInt() < 0 || value.toInt() >= keys.length) {
                    return const Text('');
                  }
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // ซ่อนตัวเลขด้านบนกราฟ
            ),
            rightTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false), // ซ่อนตัวเลขด้านขวากราฟ
            ),
          ),
          gridData: FlGridData(show: true), // ซ่อนเส้น grid
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    return Column(
      children: [
        SizedBox(
          height: 300, // เพิ่มขนาดวงกลม
          child: PieChart(
            PieChartData(
              sections: data.entries.map((entry) {
                // กำหนดสีตามสถานะ
                Color sectionColor;
                switch (entry.key) {
                  case 'รอดำเนินการ':
                    sectionColor = Colors.orange[300]!; // ส้ม
                    break;
                  case 'กำลังดำเนินการ':
                    sectionColor = Colors.blue[300]!; // น้ำเงิน
                    break;
                  case 'เสร็จสิ้น':
                    sectionColor = Colors.green[300]!; // เขียว
                    break;

                  default:
                    sectionColor = Colors.grey[300]!; // สีเริ่มต้น
                }

                return PieChartSectionData(
                  title: '', // ซ่อนข้อความในวงกลม
                  value: entry.value.toDouble(),
                  color: sectionColor, // ใช้สีที่กำหนด
                  radius: 150, // ปรับขนาดของวงกลม
                );
              }).toList(),
              sectionsSpace: 2, // ไม่มีช่องว่างระหว่างส่วนต่าง ๆ
              centerSpaceRadius: 2, // เพิ่มช่องว่างตรงกลาง
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ส่วนแสดงคำอธิบายสีและประเภท
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: data.entries.map((entry) {
            Color sectionColor;
            switch (entry.key) {
              case 'รอดำเนินการ':
                sectionColor = Colors.orange;
                break;
              case 'กำลังดำเนินการ':
                sectionColor = Colors.blue;
                break;
              case 'เสร็จสิ้น':
                sectionColor = Colors.green;
                break;
              default:
                sectionColor = Colors.grey;
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: sectionColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${entry.key} (${entry.value})",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          }).toList(),
        ),
      ],
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
