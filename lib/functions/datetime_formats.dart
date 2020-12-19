import 'package:flutter/cupertino.dart';

import 'package:timeago/timeago.dart' as timeago;

String timeAgo(DateTime dateTime) => timeago.format(dateTime);

String weekDayName(DateTime dateTime) {
  String weekDayName = '';
  switch (dateTime.weekday) {
    case 1:
      weekDayName = 'Monday';
      break;
    case 2:
      weekDayName = 'Tuesday';
      break;
    case 3:
      weekDayName = 'Wednesday';
      break;
    case 4:
      weekDayName = 'Thursday';
      break;
    case 5:
      weekDayName = 'Friday';
      break;
    case 6:
      weekDayName = 'Saturday';
      break;
    case 7:
      weekDayName = 'Sunday';
      break;
  }

  return weekDayName;
}

String monthName(DateTime dateTime) {
  String weekDayName = '';
  switch (dateTime.month) {
    case 1:
      weekDayName = 'jan';
      break;
    case 2:
      weekDayName = 'feb';
      break;
    case 3:
      weekDayName = 'mar';
      break;
    case 4:
      weekDayName = 'apr';
      break;
    case 5:
      weekDayName = 'may';
      break;
    case 6:
      weekDayName = 'jun';
      break;
    case 7:
      weekDayName = 'jul';
      break;
    case 8:
      weekDayName = 'agu';
      break;
    case 9:
      weekDayName = 'sep';
      break;
    case 10:
      weekDayName = 'oct';
      break;
    case 11:
      weekDayName = 'nov';
      break;
    case 12:
      weekDayName = 'dec';
      break;
  }

  return weekDayName;
}

String whenWasSend(DateTime dateTime) {
  var now = DateTime.now();
  String when;
  if (dateTime.day == now.day &&
      dateTime.month == now.month &&
      dateTime.year == now.year) {
    when = 'Today';
  } else if (dateTime.add(Duration(days: 1)).day == now.day &&
      dateTime.month == now.month &&
      dateTime.year == now.year) {
    when = 'Yesterday';
  } else if (now.subtract(Duration(days: 4)).day < dateTime.day &&
      dateTime.month == now.month &&
      dateTime.year == now.year) {
    when = weekDayName(dateTime);
  } else {
    when = '${dateTime.day.toString().padLeft(2, '0')}/' +
        monthName(dateTime) +
        '/${dateTime.year.toString()}';
  }

  return when;
}

String timeIn12HoursFormat(DateTime dateTime) {
  var now = DateTime.now();
  var minute = dateTime.minute.toString().padLeft(2, '0');
  String timeSuffix = '';
  String textToShow;
  var hour;

  if (dateTime.hour == 0) {
    hour = dateTime.add(Duration(hours: 12)).hour;
    timeSuffix = 'am';
  } else {
    if (dateTime.hour > 12) {
      hour = dateTime.subtract(Duration(hours: 12)).hour;
      timeSuffix = 'pm';
    } else {
      hour = dateTime.hour;
      timeSuffix = 'am';
    }
  }

  textToShow = '$hour:$minute' + ' ' + timeSuffix;

  return textToShow;
}
