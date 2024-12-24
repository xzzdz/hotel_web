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

  // ฟังก์ชั่นที่แยกเดือนและนับจำนวนการซ่อมในแต่ละเดือนตามสถานะ
  Map<String, Map<String, int>> processDataByMonthAndStatus(
      List<dynamic> reports) {
    Map<String, Map<String, int>> data = {};

    for (var report in reports) {
      String date = report['date']; // วันที่ที่เก็บในฐานข้อมูล
      String month = date.substring(5, 7); // เอาแค่เดือนจากวันที่
      String status = report['status']; // สถานะการซ่อม

      // ถ้ายังไม่มีข้อมูลเดือนนี้ใน data ให้สร้างใหม่
      if (!data.containsKey(month)) {
        data[month] = {
          'รอดำเนินการ': 0,
          'กำลังดำเนินการ': 0,
          'เสร็จสิ้น': 0,
        };
      }

      // เพิ่มจำนวนตามสถานะ
      if (status == 'รอดำเนินการ') {
        data[month]!['รอดำเนินการ'] = (data[month]!['รอดำเนินการ'] ?? 0) + 1;
      } else if (status == 'กำลังดำเนินการ') {
        data[month]!['กำลังดำเนินการ'] =
            (data[month]!['กำลังดำเนินการ'] ?? 0) + 1;
      } else if (status == 'เสร็จสิ้น') {
        data[month]!['เสร็จสิ้น'] = (data[month]!['เสร็จสิ้น'] ?? 0) + 1;
      }
    }

    return data;
  }

  // ฟังก์ชันในการดึงชื่อผู้ใช้จาก SharedPreferences
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
                elevation: 4,
                child: Sidebar(
                  username: username,
                  role: role,
                  bottonColor: bottoncolor,
                  onLogout: logout,
                ),
              ),
            ),

            // Dashboard Content
            Expanded(
              flex: 8,
              child: Card(
                elevation: 4,
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
                        final monthlyData =
                            processDataByMonthAndStatus(reports);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ข้อมูลกราฟแท่ง
                              const Text(
                                "กราฟแท่งจำนวนการแจ้งซ่อมตามเดือน",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 16.0),

                              // แสดงกราฟแท่ง
                              SizedBox(
                                height: 300,
                                child: BarChart(BarChartData(
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      axisNameSize: 16,
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      axisNameSize: 16,
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          List<String> months = [
                                            "มกราคม",
                                            "กุมภาพันธ์",
                                            "มีนาคม",
                                            "เมษายน",
                                            "พฤษภาคม",
                                            "มิถุนายน",
                                            "กรกฎาคม",
                                            "สิงหาคม",
                                            "กันยายน",
                                            "ตุลาคม",
                                            "พฤศจิกายน",
                                            "ธันวาคม"
                                          ];
                                          String month =
                                              months[value.toInt() - 1];
                                          return Text(month,
                                              style: TextStyle(fontSize: 14));
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                      show: true, drawVerticalLine: false),
                                  barGroups: monthlyData.entries.map((entry) {
                                    String month = entry.key;
                                    Map<String, int> statusData = entry.value;

                                    // กำหนดสีแท่งกราฟแต่ละเดือน
                                    Color getColorForMonth(String month) {
                                      switch (month) {
                                        case '01':
                                          return Colors.red; // มกราคม
                                        case '02':
                                          return Colors.blue; // กุมภาพันธ์
                                        case '03':
                                          return Colors.green; // มีนาคม
                                        case '04':
                                          return Colors.yellow; // เมษายน
                                        case '05':
                                          return Colors.orange; // พฤษภาคม
                                        case '06':
                                          return Colors.purple; // มิถุนายน
                                        case '07':
                                          return Colors.cyan; // กรกฎาคม
                                        case '08':
                                          return Colors.teal; // สิงหาคม
                                        case '09':
                                          return Colors.indigo; // กันยายน
                                        case '10':
                                          return Colors.brown; // ตุลาคม
                                        case '11':
                                          return Colors.pink; // พฤศจิกายน
                                        case '12':
                                          return Colors.lime; // ธันวาคม
                                        default:
                                          return Colors.grey; // เดือนอื่น ๆ
                                      }
                                    }

                                    return BarChartGroupData(
                                      x: int.parse(month),
                                      barRods: [
                                        BarChartRodData(
                                          toY: statusData.values
                                              .fold(0,
                                                  (prev, curr) => prev + curr)
                                              .toDouble(),
                                          color: getColorForMonth(
                                              month), // ใช้สีตามเดือน
                                          width: 16,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  alignment: BarChartAlignment.spaceAround,
                                )),
                              ),
                              const SizedBox(height: 16),

                              // ข้อมูลสถานะการแจ้งซ่อม
                              const Text(
                                "รายงานสรุปการแจ้งซ่อม",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 16.0),
                              // รายงานการแจ้งซ่อมที่ยังไม่ได้ดำเนินการ
                              Card(
                                elevation: 4,
                                child: ListTile(
                                  title: const Text(
                                    "รอดำเนินการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "จำนวน: ${monthlyData.values.fold(0, (prev, element) => prev + (element['รอดำเนินการ'] ?? 0))} รายการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),

                              // รายงานการแจ้งซ่อมที่กำลังดำเนินการ
                              Card(
                                elevation: 4,
                                child: ListTile(
                                  title: const Text(
                                    "กำลังดำเนินการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "จำนวน: ${monthlyData.values.fold(0, (prev, element) => prev + (element['กำลังดำเนินการ'] ?? 0))} รายการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),

                              // รายงานการแจ้งซ่อมที่เสร็จสมบูรณ์
                              Card(
                                elevation: 4,
                                child: ListTile(
                                  title: const Text(
                                    "เสร็จสิ้น",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "จำนวน: ${monthlyData.values.fold(0, (prev, element) => prev + (element['เสร็จสิ้น'] ?? 0))} รายการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),

                              // รายงานการแจ้งซ่อมทั้งหมด
                              Card(
                                elevation: 4,
                                child: ListTile(
                                  title: const Text(
                                    "ทั้งหมด",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "จำนวน: ${monthlyData.values.fold(0, (prev, element) => prev + ((element['รอดำเนินการ'] ?? 0) + (element['กำลังดำเนินการ'] ?? 0) + (element['เสร็จสิ้น'] ?? 0)))} รายการ",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
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
