extension DoubleExtension on double {
  String get priceFormat {
    return "$this EGP";
  }
}

Map<int, String> monthsNames = {
  1: "Jan",
  2: "Feb",
  3: "Mar",
  4: "Apr",
  5: "May",
  6: "Jun",
  7: "Jul",
  8: "Aug",
  9: "Sep",
  10: "Oct",
  11: "Nov",
  12: "Dec"
};


extension DateTimeExtension on DateTime {
  double get timeStamp {
    return microsecondsSinceEpoch / 1000000;
  }

  String get dateFormat {
    return "$monthShortName $day, $year";
  }

  String get timeFormat {
    int hour12Form = hour > 12 ? hour - 12 : hour;
    String pmOrAm = hour > 12 ? "P.M" : "A.M";
    return "$hour12Form:${minute.toString().padLeft(2, "0")} $pmOrAm";
  }

  String get monthShortName {
    return monthsNames[month]!;
  }
}


