import 'dart:io';
import 'package:account/model/transactionItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TransactionDB {
  String dbName;

  TransactionDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    Future<int> keyID = store.add(db, {
      'title': item.title,
      'amount': item.amount,
      'date': item.date?.toIso8601String(),
      'imagePath': item.imagePath,
      'checkInDate': item.checkInDate?.toIso8601String(),
      'checkOutData': item.checkOutData,
      'position': item.position, // เพิ่มตำแหน่งงาน
    });
    db.close();
    return keyID;
  }

  Future<List<TransactionItem>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    var snapshot = await store.find(db,
        finder: Finder(sortOrders: [SortOrder('date', false)]));
    
    List<TransactionItem> transactions = [];

    for (var record in snapshot) {
      TransactionItem item = TransactionItem(
        keyID: record.key,
        title: record['title'].toString(),
        amount: double.parse(record['amount'].toString()),
        date: record['date'] != null ? DateTime.parse(record['date'].toString()) : null,
        imagePath: record['imagePath'] as String?,
        checkInDate: record['checkInDate'] != null
            ? DateTime.parse(record['checkInDate'].toString())
            : null,
        checkOutData: record['checkOutData'] as String?,
        position: record['position'] as String?, // อ่านตำแหน่งงาน
      );
      transactions.add(item);
    }
    db.close();
    return transactions;
  }

  deleteData(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    store.delete(db,
        finder: Finder(filter: Filter.equals(Field.key, item.keyID)));
    db.close();
  }

  updateData(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    store.update(
        db,
        {
          'title': item.title,
          'amount': item.amount,
          'date': item.date?.toIso8601String(),
          'imagePath': item.imagePath,
          'checkInDate': item.checkInDate?.toIso8601String(),
          'checkOutData': item.checkOutData,
          'position': item.position, // อัปเดตตำแหน่งงาน
        },
        finder: Finder(filter: Filter.equals(Field.key, item.keyID))
    );

    db.close();
  }
}
