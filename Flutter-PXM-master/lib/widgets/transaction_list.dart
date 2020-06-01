import 'package:flutter/material.dart';
import 'package:pers_exp_mon/models/exptrans.dart';

import 'transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  final List<ExpTrans> transactions;
  final Function deleteTx;

  TransactionList(this.transactions, this.deleteTx);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: transactions.isEmpty
          ? LayoutBuilder(builder: (ctx, constraints) {
              return Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No Transactions Added yet!',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Image.asset(
                    'assets/images/waiting.png',
                    height: constraints.maxHeight * 0.6,
                  ),
                ],
              );
            })
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  elevation: 5,
                  child: TransactionListItem(transactions[index],deleteTx),
                );
              },
              itemCount: transactions.length,
            ),
    );
  }
}
