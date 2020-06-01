import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pers_exp_mon/models/exptrans.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider with ChangeNotifier {

  Database _database;

  static const String TABLENAME = "PXM";
  static const String COLID = "id";
  static const String COLTITLE = "title";
  static const String COLAMOUNT = "amount";
  static const String COLDATE = "date";

  Future<Database> get database async {
    print('Someone asked for Database onject');
    if (_database == null) {
      print('Database Object is not found now initializing database');
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    print('I am at initialization stage');
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'PXMDATA.db';
    var database = openDatabase(path, version: 1, onCreate: _createDB);
    return database;
  }

  void _createDB(Database db, int newVersion) async {
    print('I am going to create a new table');
    await db.execute(
        "CREATE TABLE $TABLENAME($COLID TEXT PRIMARY KEY,$COLTITLE TEXT, $COLAMOUNT REAL,$COLDATE TEXT)");
  }

  Future<List<ExpTrans>> getTransactionList() async {
    print('I am here to get the list of Transactions');
    Database db = await this.database;
    List<Map<String, dynamic>> mapList = await db.query(TABLENAME);
    int count = mapList.length;
    List<ExpTrans> list = List<ExpTrans>();

    for (int i = 0; i < count; i++) {
      print('I am getting index :$i');
      list.add(ExpTrans.fromMapObject(mapList[i]));
    }
    return list;
  }

  Future<void> insertNewExpTrans(ExpTrans expTrans) async {
    print("I am here to insert a new transaction");
    Database db = await this.database;
    await db.insert(TABLENAME, expTrans.toMap());
  }

  Future<void> deletExpTrans(String id) async {
    print('I am here to Delete a Transaction');
    Database db = await this.database;
    await db.rawDelete("DELETE FROM $TABLENAME WHERE $COLID = '$id'");
  }

  Future<void> deleteTableAndDatabase() async {
    print('I am here to Delete Table and Database');
    Database db = await this.database;
    await db.execute("DROP TABLE $TABLENAME");
    await db.close();
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'PXMDATA.db';
    await databaseFactory.deleteDatabase(path);
  }
}
