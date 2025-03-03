import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool isRecognized = false;
  DateTime? checkOutTime;

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

  // ฟังก์ชันสแกนใบหน้าเพื่อเช็คเอาท์ (เปิดกล้อง)
  Future<void> _scanFace() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isRecognized = true;
        checkOutTime = DateTime.now();
        _animationController.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ค้นหา pending record ที่มี checkInDate แต่ยังไม่มี checkOutData
    final provider = Provider.of<TransactionProvider>(context);
    TransactionItem? pending;
    for (var item in provider.transactions.reversed) {
      if (item.checkInDate != null && item.checkOutData == null) {
        pending = item;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-Out"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pending == null
            ? const Center(child: Text("ไม่พบข้อมูลการเข้างาน"))
            : ListView(
                children: [
                  // แสดงข้อมูลของบุคคลที่กำลังเช็คเอาท์
                  Card(
                    color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          pending.title.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      title: Text(
                        pending.title,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        'ตำแหน่ง: ${pending.position ?? "-"}\n'
                        'เวลาเข้างาน: ${pending.checkInDate?.toLocal().toString().split(".")[0] ?? "-"}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "สแกนใบหน้าเพื่อบันทึกเวลาออกงาน",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // ปุ่มสแกนใบหน้า
                  ElevatedButton.icon(
                    onPressed: _scanFace,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("สแกนใบหน้าเพื่อบันทึกเวลาออกงาน"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 189, 176, 212),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // แสดง UI สแกนใบหน้าที่ตกแต่งแบบ "สองกรอบซ้อนกัน" พร้อม Animation
                  buildCreativeScanFrame(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (isRecognized && checkOutTime != null) {
                        pending!.checkOutData = checkOutTime!.toIso8601String();
                        provider.updateTransaction(pending);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("กรุณาสแกนใบหน้าเพื่อบันทึกเวลาออกงาน")),
                        );
                      }
                    },
                    child: const Text("บันทึกการออกงาน"),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: const Color.fromARGB(255, 187, 171, 216),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ฟังก์ชันสร้าง UI สแกนใบหน้าแบบ "สองกรอบซ้อนกัน" พร้อม Animation เส้นสแกน
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
