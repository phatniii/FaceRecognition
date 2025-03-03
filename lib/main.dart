import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'package:account/checkOutScreen.dart';
import 'package:account/dashboardScreen.dart';
import 'package:account/editScreen.dart';
import 'package:provider/provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'บันทึกการเข้าออกงานของพนักงาน'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  
  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.initData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dashboard
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.dashboard,
                                size: 40,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Dashboard",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.login,
                                size: 40,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "เข้างาน",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CheckOutScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.logout,
                                size: 40,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "ออกงาน",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // รายการการบันทึกงาน (GridView)
              Expanded(
                child: provider.transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'ไม่มีรายการ',
                          style: TextStyle(fontSize: 30),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          TransactionItem data = provider.transactions[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EditScreen(item: data);
                              }));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: data.imagePath != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(data.imagePath!),
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover, // ใช้ BoxFit.cover เพื่อให้ภาพแสดงเต็มกรอบ
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 40,
                                                backgroundColor: Colors.deepPurple[50],
                                                child: Text(
                                                  data.title.isNotEmpty
                                                      ? data.title[0].toUpperCase()
                                                      : '',
                                                  style: TextStyle(
                                                    color: Colors.deepPurple[300],
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // เพิ่มการแสดงตำแหน่งงาน
                                    if (data.position != null && data.position!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'ตำแหน่ง: ${data.position}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    // แสดงวันที่และเวลาในรูปแบบที่ต้องการ
                                    Text(
                                      'เข้างาน: ${data.checkInDate != null ? formatDateTime(data.checkInDate!) : "-"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'ออกงาน: ${data.checkInDate != null ? formatDateTime(data.checkInDate!) : "-"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    // เพิ่มไอคอนถังขยะเพื่อการลบข้อมูล
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          provider.deleteTransaction(data);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ฟังก์ชันที่ใช้ในการแสดงวันที่และเวลาในรูปแบบ 2025-03-03 09:52 น.
  String formatDateTime(DateTime dateTime) {
    return "${dateTime.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)} น.";
  }
}
