import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyDateUtil {
  // for getting formatted time from milliSecondsSinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    if (now.year == sent.year) {
      return '${sent.month}월 ${sent.day}일';
    }
    return '${sent.year}년 ${sent.month}월 ${sent.day}일';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActivce}) {
    final int i = int.tryParse(lastActivce) ?? -1;

    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return TimeOfDay.fromDateTime(time).format(context);
    }
    if (now.year == time.year) {
      return '${time.month}월 ${time.day}일';
    }
    return '${time.year}년 ${time.month}월 ${time.day}일';
  }

  static String getOrgTime({required BuildContext, context, required String date}) {
    final DateTime orgTime = DateTime.fromMillisecondsSinceEpoch(int.parse(date));
    return '${orgTime.year}년 ${orgTime.month}월 ${orgTime.day}일';
  }
}
