import 'package:intl/intl.dart';

class myDateTime {
  static DateTime dateFormat(String time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return DateTime(dateTime.day, dateTime.month, dateTime.year);
  }

  static String onlyTime(String time) {
    String t = '';
    var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    t = DateFormat('jm').format(dateTime).toString();

    return t;
  }

  static String dateAndTime(String time) {
    String dateTime = '';

    var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    final today = DateTime.now();
    final yesterday = DateTime.now().add(const Duration(days: -1));

    final t = DateTime(today.year, today.month, today.day);
    final y = DateTime(yesterday.year, yesterday.month, yesterday.day);

    final d = DateTime(dt.year, dt.month, dt.day);

    if(d==t){
      dateTime='Today';
    }else if(d==y){
      dateTime='Yesterday';
    }else if(dt.year==today.year){
      dateTime=DateFormat.MMMd().format(dt).toString();
    }else{
      dateTime=DateFormat.yMMMd().format(dt).toString();

    }

    return dateTime;
  }
}
