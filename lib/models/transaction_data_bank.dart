import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data.dart';

class TransactionDataBank extends ChangeNotifier {
  List<Data> _TransactionList = [];
  Map<DateTime, List<Data>> _TransactionMap = HashMap();
  //working
  void setTransactionList(List<Data> list) {
    _TransactionList = list;
    notifyListeners();
    addItem();
  }

  //get daily total for the dates from weeklist from dailytotal map
  Map<DateTime, double> _DailyTotalTransactionMap = HashMap();
  //total for a day in general
  void getDailyTotal() {
    _TransactionMap.forEach((key, value) {
      //date=>[Data,Data...] data in that list is getting summed up
      // below ouptut is date=>sum
      //put this in dailytotal map
      double total =
          value.fold<double>(0, (double sum, Data item) => sum + item.amount!);
      _DailyTotalTransactionMap.update(key, (value) => total,
          ifAbsent: () => total);
    });
    //sort the map in ascending order by datewise
    final mapOf = SplayTreeMap<DateTime, double>.of(_DailyTotalTransactionMap);
    print("DailyTotal Map ${mapOf}");
  }

  //works from method makeAWeek()
  Map<int, DateTime?> _weekList = HashMap();
  void makeAWeek() {
    _weekList = {0: null, 1: null, 2: null, 3: null, 4: null, 5: null, 6: null};
    //get today's date
    DateTime newDate = DateTime.now();
    DateTime fmd = newDate.subtract(Duration(
        hours: newDate.hour,
        minutes: newDate.minute,
        seconds: newDate.second,
        milliseconds: newDate.millisecond,
        microseconds: newDate.microsecond));
    //suppose its 13/7 ; convert this to (int)dayno. = wed=3 (date.weekday);
    int dayno = fmd.weekday;
    //if leftrange =0 then no left range but right =6
    int leftRangeNegative = 1 - dayno;
    int leftRange = leftRangeNegative.abs();
    int rightRange = 7 - dayno;
    int i = 0;
    //days before today's date starting from monday till yesterday
    while (leftRange != 0) {
      DateTime newDate = fmd.subtract(Duration(days: leftRange));
      _weekList.update(i, (value) => newDate);
      i++;
      //weekList.add(newDate);
      leftRange--;
    }
    //today's date
    _weekList.update(i, (value) => fmd);
    i++;
    //weekList.add(fmd);
    int j = 1;
    while (j != rightRange + 1) {
      DateTime newDate = fmd.add(Duration(days: j));
      _weekList.update(i, (value) => newDate);
      i++;
      //weekList.add(newDate);
      j++;
    }
    notifyListeners();
    print("reqDateList = ${_weekList.toString()}");
    //for(int )
    //from daily total transaction get me left range which is total days from the left of the curr day
    // i.e M T => |1-dayno.| => expected output = |1-3=-2|=2
  }

  //daily total for the curr week
  Map<int, double> _dailyTotal = HashMap();
  void weeklyData() {
    print(
        "========== weeklist lenght ${_weekList.length} ====================");
    _dailyTotal = {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0};
    double? x = 0.0;
    for (int i = 0; i < _weekList.length; i++) {
      if (_DailyTotalTransactionMap.containsKey(_weekList[i])) {
        x = _DailyTotalTransactionMap[_weekList[i]];
      } else {
        x = 0.0;
      }
      _dailyTotal.update(i, (value) => x!);
    }
    print("dailyTotal= ${_dailyTotal}");
  }

  void clearDailyTotal() {
    _dailyTotal.clear();
    notifyListeners();
  }

  List<double> getDailyTotalList() {
    List<double> result = _dailyTotal.entries.map((e) => e.value).toList();
    double total =
        result.fold<double>(0, (double sum, double item) => sum + item);
    for (int k = 0; k < result.length; k++) {
      result[k] = (result[k] / total) * 10;
    }
    return result;
  }

  //give a proper name
  void printlist(List<Data> list) {
    for (Data i in list) {
      print("from bank = title = ${i.title} time = ${i.amount} id = ${i.id}");
    }
  }

  // Is a HashMap
  void addItem() {
    //remove this by rewiring widgets
    // _TransactionList.add(data);
    // if (!_TransactionMap.containsKey(data.date)) {
    //   _TransactionMap.addAll({
    //     data.date!: [data]
    //   });
    // } else {
    //   _TransactionMap.update(data.date!, (value) {
    //     return [data, ...?_TransactionMap[data.date]];
    //   });
    // }
    printlist(_TransactionList);

    if (_TransactionList.isEmpty) {
      return;
    }
    _TransactionMap.clear();
    _DailyTotalTransactionMap.clear();
    _dailyTotal.clear();
    for (int i = 0; i < _TransactionList.length; i++) {
      if (!_TransactionMap.containsKey(_TransactionList[i].date)) {
        _TransactionMap.addAll({
          _TransactionList[i].date!: [_TransactionList[i]]
        });
      } else {
        _TransactionMap.update(_TransactionList[i].date!, (value) {
          return [
            _TransactionList[i],
            ...?_TransactionMap[_TransactionList[i].date]
          ];
        });
      }
    }
    getDailyTotal();
    //this is how you gate the day of the week 0-Monday ...
    //print("task day = ${_TransactionList[i].date!.weekday}");
    print(_TransactionMap);
    makeAWeek();
    weeklyData();
    notifyListeners();
  }

  //rewire this
  List<Data> getList() {
    //todo
    //take today's day as input and get that list from the map and return it
    return _TransactionList;
  }

  Data getItemAtIndex({required int index}) {
    return _TransactionList[index];
  }

  int getSize() {
    return _TransactionList.length;
  }

  void deleteItemAtIndex({required int index}) {
    //_TransactionList.removeAt(index);
    _TransactionMap.removeWhere((key, value) => false);
    notifyListeners();
  }
}
