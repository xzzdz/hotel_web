import 'package:flutter/material.dart';
import 'package:hotel_web/constant/color_font.dart';

// Form Key และ Controllers สามารถส่งมาจาก Parent Widget
class AddUserForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController roleController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const AddUserForm({
    Key? key,
    required this.formKey,
    required this.roleController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Field
          DropdownButtonFormField<String>(
            value: widget.roleController.text.isNotEmpty
                ? widget.roleController.text
                : null,
            decoration: const InputDecoration(
              labelText: 'ตำแหน่ง',
              border: OutlineInputBorder(),
            ),
            items: ['ผู้ดูแลระบบ', 'พนักงาน', 'ช่างซ่อม'].map((role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                widget.roleController.text = value!;
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
            controller: widget.nameController,
            decoration: const InputDecoration(
              labelText: 'ชื่อ - นามสกุล',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อ - นามสกุล';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Email Field
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'ชื่อผู้ใช้งาน',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Password Field
          TextFormField(
            controller: widget.passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'รหัสผ่าน',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                if (widget.formKey.currentState!.validate()) {
                  widget.onSubmit();
                  Navigator.pop(context);
                  // แสดงข้อความเตือนเมื่อการลบสำเร็จ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('บันทึกผู้ใช้สําเร็จ'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
    );
  }
}
