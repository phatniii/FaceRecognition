import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  final TransactionItem item;
  
  const EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final positionController = TextEditingController(); // สำหรับตำแหน่งงาน

  File? _image;
  bool isRecognized = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นจาก widget.item
    titleController.text = widget.item.title;
    positionController.text = widget.item.position ?? '';
    _image = widget.item.imagePath != null ? File(widget.item.imagePath!) : null;
    isRecognized = _image != null;

    // ตั้งค่า AnimationController
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

  // ฟังก์ชันเลือกภาพจาก Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isRecognized = true;
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
        title: const Text('Edit Transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              // ช่องกรอกชื่อ-นามสกุล
              TextFormField(
                controller: titleController,
                decoration: buildInputDecoration(
                  label: 'ชื่อ-นามสกุล',
                  icon: Icons.person_outline,
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนชื่อ-นามสกุล";
                  }
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
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนตำแหน่งงาน";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ลบช่องกรอกอายุออกจากฟอร์ม

              const SizedBox(height: 20),

              // ปุ่มเลือกภาพ
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('เลือกภาพ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 189, 176, 212),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ส่วนแสดงรูปภาพในกรอบสองชั้น
              buildCreativeScanFrame(),
              const SizedBox(height: 30),

              // ปุ่มบันทึกข้อมูล
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final provider = Provider.of<TransactionProvider>(context, listen: false);

                    final item = TransactionItem(
                      keyID: widget.item.keyID,
                      title: titleController.text,
                      position: positionController.text,
                      amount: 0, // กำหนดให้เป็น 0 เนื่องจากไม่กรอกอายุ
                      date: widget.item.date,
                      imagePath: _image?.path,
                      checkInDate: widget.item.checkInDate,
                      checkOutData: widget.item.checkOutData,
                    );

                    provider.updateTransaction(item);
                    Navigator.pop(context);
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
                  'แก้ไขข้อมูล',
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

  /// สร้าง UI สแกนใบหน้าสองกรอบ + AnimatedBuilder
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
                          color: Colors.grey.shade400,
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
          // ป้าย "RECOGNIZED 100%" เมื่อเลือกรูปแล้ว
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
