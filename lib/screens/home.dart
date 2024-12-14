import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../color.dart';
import 'detail.dart';
import 'login.dart';

class HomepageWeb extends StatefulWidget {
  const HomepageWeb({Key? key}) : super(key: key);

  @override
  State<HomepageWeb> createState() => _HomepageWebState();
}

class _HomepageWebState extends State<HomepageWeb> {
  String? username;
  String? role;
  int currentPage = 0;
  // final int itemsPerPage = 5;
  String? selectedType = 'ทั้งหมด';
  String? selectedStatus = 'ทั้งหมด';
  List<String> types = ['ทั้งหมด', 'ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = [
    'ทั้งหมด',
    'รอดำเนินการ',
    'กำลังดำเนินการ',
    'เสร็จสิ้น'
  ];

  Future<List<dynamic>> allReport() async {
    var url = "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
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
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: bottoncolor, // สีพื้นหลัง
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 20),
                          child: Column(
                            children: [
                              Container(
                                width: 80, // ขนาดของรูปโปรไฟล์
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, // รูปแบบวงกลม
                                  image: const DecorationImage(
                                    image: AssetImage('assets/img/runnerx.png'),
                                    fit: BoxFit.cover, // ปรับรูปให้เต็มพื้นที่
                                  ),
                                  border: Border.all(
                                    color: Colors.white, // ขอบสีขาว
                                    width: 2, // ความหนาของขอบ
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                username ?? '', // แสดงเฉพาะชื่อ
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'ตำแหน่ง : ${role ?? ''}', // แสดงตำแหน่ง
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text("หน้าหลัก"),
                      onTap: () {},
                    ),
                    Divider(),
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text("รายการแจ้งซ่อม"),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomepageWeb(),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("จัดการผู้ใช้งาน"),
                      onTap: () {},
                    ),
                    Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("ออกจากระบบ"),
                      onTap: () {
                        logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Expanded(
              flex: 8,
              child: FutureBuilder<List<dynamic>>(
                future: allReport(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredData = snapshot.data!.where((item) {
                    return (selectedType == 'ทั้งหมด' ||
                            item['type'] == selectedType) &&
                        (selectedStatus == 'ทั้งหมด' ||
                            item['status'] == selectedStatus);
                  }).toList();

                  int rowsPerPage = 5; // กำหนดจำนวนแถวต่อหน้า
                  int totalPages = (filteredData.length / rowsPerPage).ceil();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dashboard Section
                            Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDashboardItem(
                                        "รอดำเนินการ",
                                        filteredData
                                            .where((item) =>
                                                item['status'] == 'รอดำเนินการ')
                                            .length),
                                    _buildDashboardItem(
                                        "กำลังดำเนินการ",
                                        filteredData
                                            .where((item) =>
                                                item['status'] ==
                                                'กำลังดำเนินการ')
                                            .length),
                                    _buildDashboardItem(
                                        "เสร็จสิ้น",
                                        filteredData
                                            .where((item) =>
                                                item['status'] == 'เสร็จสิ้น')
                                            .length),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Filters Section
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                      "ประเภท", types, selectedType, (value) {
                                    setState(() {
                                      selectedType = value;
                                    });
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdown(
                                      "สถานะ", statuses, selectedStatus,
                                      (value) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Data Table with Pagination
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minWidth: constraints.maxWidth),
                                            child: DataTable(
                                              columnSpacing: 16.0,
                                              headingRowHeight: 50,
                                              dataRowHeight: 60,
                                              columns: const [
                                                DataColumn(
                                                  label: Text(
                                                    "วันที่",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "ประเภท",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "สถานะ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "รายละเอียด",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "ดูเพิ่มเติม",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              rows: filteredData
                                                  .skip(
                                                      currentPage * rowsPerPage)
                                                  .take(rowsPerPage)
                                                  .map((item) {
                                                Color statusColor;

                                                // กำหนดสีและไอคอนตามสถานะ
                                                switch (item['status']) {
                                                  case 'รอดำเนินการ':
                                                    statusColor = Colors.orange;

                                                    break;
                                                  case 'กำลังดำเนินการ':
                                                    statusColor = Colors.blue;

                                                    break;
                                                  case 'เสร็จสิ้น':
                                                    statusColor = Colors.green;

                                                    break;
                                                  default:
                                                    statusColor = Colors.grey;
                                                }

                                                return DataRow(cells: [
                                                  DataCell(Text(item['date'])),
                                                  DataCell(Text(item['type'])),
                                                  DataCell(Row(
                                                    children: [
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        item['status'],
                                                        style: TextStyle(
                                                            color: statusColor,
                                                            fontWeight: FontWeight
                                                                .bold), // สีของข้อความสถานะ
                                                      ),
                                                    ],
                                                  )),
                                                  DataCell(
                                                    SizedBox(
                                                      width:
                                                          200, // กำหนดความกว้างที่ต้องการ
                                                      child: Text(
                                                        item['detail'].length >
                                                                20
                                                            ? item['detail']
                                                                    .substring(
                                                                        0, 20) +
                                                                '...'
                                                            : item[
                                                                'detail'], // ตัดข้อความที่เกิน 20 ตัวอักษร
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    IconButton(
                                                      color: bottoncolor,
                                                      icon: const Icon(
                                                          Icons.info),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                Detail(
                                                                    item: item),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ]);
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Pagination Controls
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.first_page,
                                              color: Colors.white),
                                          label: const Text(
                                            "หน้าแรก",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed: currentPage > 0
                                              ? () {
                                                  setState(() {
                                                    currentPage = 0;
                                                  });
                                                }
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.arrow_back,
                                              color: Colors.white),
                                          label: const Text(
                                            "ก่อนหน้า",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed: currentPage > 0
                                              ? () {
                                                  setState(() {
                                                    currentPage--;
                                                  });
                                                }
                                              : null,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            "หน้า ${currentPage + 1} จาก ${totalPages}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.arrow_forward,
                                              color: Colors.white),
                                          label: const Text(
                                            "ถัดไป",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed:
                                              currentPage < totalPages - 1
                                                  ? () {
                                                      setState(() {
                                                        currentPage++;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.last_page,
                                              color: Colors.white),
                                          label: const Text(
                                            "หน้าสุดท้าย",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed:
                                              currentPage < totalPages - 1
                                                  ? () {
                                                      setState(() {
                                                        currentPage =
                                                            totalPages - 1;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(String title, int count) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
