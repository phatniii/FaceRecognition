import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:account/model/transactionItem.dart';

// เพิ่มไฟล์ detailScreen.dart
import 'package:account/detailScreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    // กรองเฉพาะรายการที่มีการเช็คอิน
    final checkInList = transactions.where((t) => t.checkInDate != null).toList();

    // กรองเฉพาะรายการของวันนี้
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayCheckIn = checkInList.where((t) {
      return t.checkInDate!.isAfter(startOfToday) &&
          t.checkInDate!.isBefore(endOfToday);
    }).toList();

    // กำหนดเวลา threshold (09:00)
    final onTimeThreshold = DateTime(now.year, now.month, now.day, 10, 0, 0);

    // แบ่งรายการที่มาตรงเวลาและมาสาย
    final onTimeList = todayCheckIn.where((t) {
      return t.checkInDate!.isBefore(onTimeThreshold) ||
          t.checkInDate!.isAtSameMomentAs(onTimeThreshold);
    }).toList();
    final lateList = todayCheckIn.where((t) {
      return t.checkInDate!.isAfter(onTimeThreshold);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวข้อ Dashboard
            Text(
              "สรุปสถิติการทำงานประจำวัน",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 20),

            // ตัวอย่าง: Row แรก 2 card
            Row(
              children: [
                // การ์ด 1: จำนวนคนที่เข้ามาทำงานวันนี้
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // กดการ์ดนี้ -> ไปหน้า DetailScreen แสดง todayCheckIn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: "คนที่เข้ามาทำงานวันนี้",
                            items: todayCheckIn,
                          ),
                        ),
                      );
                    },
                    child: buildStatCard(
                      title: "จำนวนคนที่เข้ามาทำงานวันนี้",
                      count: todayCheckIn.length,
                      color: Colors.deepPurple,
                      icon: Icons.person,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // การ์ด 2: มาตรงเวลา
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // กดการ์ดนี้ -> ไปหน้า DetailScreen แสดง onTimeList
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: "คนที่มาตรงเวลา (ก่อน 10:00)",
                            items: onTimeList,
                          ),
                        ),
                      );
                    },
                    child: buildStatCard(
                      title: "มาตรงเวลา (ก่อน 10:00)",
                      count: onTimeList.length,
                      color: Colors.blue,
                      icon: Icons.timer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ตัวอย่าง: Row ที่สอง 1 card
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // กดการ์ดนี้ -> ไปหน้า DetailScreen แสดง lateList
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: "คนที่มาสาย (หลัง 10:00)",
                            items: lateList,
                          ),
                        ),
                      );
                    },
                    child: buildStatCard(
                      title: "มาสาย (หลัง 10:00)",
                      count: lateList.length,
                      color: Colors.orange,
                      icon: Icons.timer_off,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required int count,
    required MaterialColor color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ไอคอนในวงกลม
          CircleAvatar(
            radius: 24,
            backgroundColor: color.shade100,
            child: Icon(
              icon,
              color: color.shade700,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // ชื่อสถิติ
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: color.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // แสดงจำนวน
          Text(
            "$count คน",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
