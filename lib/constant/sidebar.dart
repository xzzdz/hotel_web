import 'package:flutter/material.dart';

import '../screens/add_report.dart';
import '../screens/add_users.dart';
import '../screens/home.dart';

class Sidebar extends StatelessWidget {
  final String? username;
  final String? role;
  final Color bottonColor;
  final VoidCallback onLogout;

  const Sidebar({
    Key? key,
    required this.username,
    required this.role,
    required this.bottonColor,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bottonColor, // สีพื้นหลัง
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
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
                        fontFamily: 'Font_.Fonts_T',
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
                        fontFamily: 'Font_.Fonts_T',
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
          const Divider(),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("เพิ่มการแจ้งซ่อม"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReport(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("จัดการผู้ใช้งาน"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUsers(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("ออกจากระบบ"),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
