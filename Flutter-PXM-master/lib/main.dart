import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pers_exp_mon/providers/databaseProvider.dart';
import 'package:pers_exp_mon/widgets/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './models/exptrans.dart';

void main() {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: DatabaseProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Expenses',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.amber,
          errorColor: Colors.red,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
              title: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              button: const TextStyle(color: Colors.white)),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: const TextStyle(
                    fontFamily: 'Opensans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<ExpTrans> _userTransactions = [];
  bool _isLoading = true;

  List<ExpTrans> get _recentTransactions {
    return _userTransactions.where((tx) {
      var mdate = DateTime.parse(tx.date);
      return mdate.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    fetchUserTrans();
  }

  void fetchUserTrans() async {
    await Provider.of<DatabaseProvider>(context, listen: false)
        .getTransactionList()
        .then((list) {
      setState(() {
        _isLoading = false;
        _userTransactions = list;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//!
  Future<void> _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) async {
    final newTx = ExpTrans(
      title: txTitle,
      amount: txAmount,
      date: chosenDate.toString(),
      id: DateTime.now().toString(),
    );

    await Provider.of<DatabaseProvider>(context, listen: false)
        .insertNewExpTrans(newTx)
        .then((_) {
      setState(() {
        _userTransactions.add(newTx);
      });
    });
  }

//!
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: New_Transaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

// !
  Future<void> deleteTransaction(String id) async {
    await Provider.of<DatabaseProvider>(context, listen: false)
        .deletExpTrans(id)
        .then((_) {
      setState(() {
        _userTransactions.removeWhere((tx) {
          return tx.id == id;
        });
      });
    });
  }

// !
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Pers Exp.'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Show Chart',
                  style:
                      TextStyle(fontFamily: 'Open Sans', color: Colors.white),
                ),
                Switch.adaptive(
                  value: _showChart,
                  onChanged: (val) {
                    setState(() {
                      _showChart = val;
                    });
                  },
                ),
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: const Text(
              'Pers Exp.',
              style: TextStyle(fontFamily: 'Open Sans', color: Colors.white),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Show Chart',
                    style:
                        TextStyle(fontFamily: 'Open Sans', color: Colors.white),
                  ),
                  Switch.adaptive(
                    value: _showChart,
                    onChanged: (val) {
                      setState(() {
                        _showChart = val;
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_showChart && isLandscape)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    1,
                child: Chart(_recentTransactions),
              ),
            if (_showChart && isLandscape == false)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.3,
                child: Chart(_recentTransactions),
              ),
             if (_showChart && isLandscape == false)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.7,
                child: TransactionList(_userTransactions, deleteTransaction),
              ),
             if (_showChart == false && isLandscape == false)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    1,
                child: TransactionList(_userTransactions, deleteTransaction),
              )
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : _isLoading
            ? Scaffold(
                body: Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/images/logo.jpg')),
                ),
              )
            : Scaffold(
                appBar: appBar,
                body: pageBody,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Platform.isIOS
                    ? Container()
                    : FloatingActionButton(
                        child: const Icon(Icons.add),
                        onPressed: () => _startAddNewTransaction(context),
                      ),
              );
  }
}
