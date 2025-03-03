class TransactionItem {
  int? keyID;
  String title;
  double amount;
  DateTime? date;
  String? imagePath; // สำหรับเก็บรูปใบหน้า
  DateTime? checkInDate;   // เวลาเช็คอิน
  String? checkOutData;    // เวลาเช็คเอาท์ (หรือข้อมูลเพิ่มเติม)
  String? position;        // ตำแหน่งงานที่ผู้ใช้กรอก

  TransactionItem({
    this.keyID,
    required this.title,
    required this.amount,
    this.date,
    this.imagePath,
    this.checkInDate,
    this.checkOutData,
    this.position,
  });
}
