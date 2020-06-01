import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pers_exp_mon/models/exptrans.dart';

class TransactionListItem extends StatelessWidget {
  final ExpTrans transaction;
  final Function deleteTx;

  TransactionListItem(this.transaction,this.deleteTx);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: FittedBox(
            child: Text(
              '\u20B9' + transaction.amount.toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      title: Text(
        transaction.title,
        style: Theme.of(context).textTheme.title,
      ),
      subtitle: Text(
        DateFormat().format(DateTime.parse(transaction.date)),
      ),
      trailing: MediaQuery.of(context).size.width > 360
          ? FlatButton.icon(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: const Text(
                'Delete',
                style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () => deleteTx(transaction.id),
              color: Theme.of(context).errorColor,
            )
          : IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () => deleteTx(transaction.id),
            ),
    );
  }
}
