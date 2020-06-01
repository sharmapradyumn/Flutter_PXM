import 'package:flutter/foundation.dart';

class ExpTrans {
  String id;
  String title;
  double amount;
  String date;

  ExpTrans({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });

  ExpTrans.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.amount = map['amount'];
    this.date = map['date'];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['amount'] = amount;
    map['date'] = date;
    return map;
  }
}
