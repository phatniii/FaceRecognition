import 'package:flutter/material.dart';
import 'package:account/model/transactionItem.dart';
import 'dart:io';

class DetailScreen extends StatelessWidget {
  final String title;
  final List<TransactionItem> items;

  const DetailScreen({Key? key, required this.title, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text("ไม่พบข้อมูล"),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final data = items[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: data.imagePath != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(data.imagePath!)),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data.title),
                    subtitle: Text(
                      "เวลาเช็คอิน: ${data.checkInDate?.toLocal()}\n"
                      "เวลาเช็คเอาท์: ${data.checkOutData ?? "-"}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
