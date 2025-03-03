import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final positionController = TextEditingController(); // ช่องตำแหน่งงาน
  File? _image;
  bool isRecognized = false;
  DateTime? checkInDate;

  // Animation Controller สำหรับเส้นสแกน
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 220).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสแกนใบหน้าจากกล้อง
  Future<void> _scanFace() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isRecognized = true;
        checkInDate = DateTime.now();
        _animationController.stop();
      });
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              // ชื่อ-นามสกุล
              TextFormField(
                controller: titleController,
                decoration: buildInputDecoration(
                  label: 'ชื่อ-นามสกุล',
                  icon: Icons.person_outline,
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) return "กรุณาป้อนชื่อ-นามสกุล";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ช่องกรอกตำแหน่งงาน
              TextFormField(
                controller: positionController,
                decoration: buildInputDecoration(
                  label: 'ตำแหน่งงาน',
                  icon: Icons.work_outline,
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) return "กรุณาป้อนตำแหน่งงาน";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ลบช่องกรอกอายุออกจากฟอร์ม

              const SizedBox(height: 20),

              // ปุ่มสแกนใบหน้า (เปิดกล้อง)
              ElevatedButton.icon(
                onPressed: _scanFace,
                icon: const Icon(Icons.camera_alt),
                label: const Text('สแกนใบหน้าเพื่อบันทึกเวลาเข้างาน'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 189, 176, 212),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ส่วนแสดงผลการสแกนใบหน้าที่ตกแต่งแบบ "สองกรอบซ้อนกัน" พร้อม Animation
              buildCreativeScanFrame(),
              const SizedBox(height: 30),

              // ปุ่มบันทึกข้อมูล
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() && isRecognized) {
                    final provider =
                        Provider.of<TransactionProvider>(context, listen: false);
                    final item = TransactionItem(
                      title: titleController.text,
                      amount: 0, // กำหนดให้เป็น 0 เนื่องจากไม่กรอกอายุ
                      date: DateTime.now(),
                      imagePath: _image?.path,
                      checkInDate: checkInDate,
                      checkOutData: null,
                      position: positionController.text,
                    );
                    provider.addTransaction(item);
                    Navigator.pop(context);
                  } else if (!isRecognized) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรุณาสแกนใบหน้า")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'บันทึกเวลาเข้างาน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ฟังก์ชันสร้าง UI แบบ "สองกรอบซ้อนกัน" พร้อม Animation เส้นสแกน
  Widget buildCreativeScanFrame() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // กรอบนอก
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: isRecognized ? Colors.green : Colors.blueGrey,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // กรอบใน
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                color: isRecognized ? Colors.green : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (!isRecognized)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Positioned(
                              top: _animation.value % 220,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.blueAccent.withOpacity(0.7),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
          ),
          // ป้าย "RECOGNIZED 100%" เมื่อสแกนเสร็จแล้ว
          if (isRecognized && _image != null)
            Positioned(
              bottom: -40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'RECOGNIZED 100%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
