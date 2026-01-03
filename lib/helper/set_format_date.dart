import 'package:intl/intl.dart';

String setFormateDate([String dateFormat = 'dd-MM-yyyy']) {
  final now = DateTime.now();
  final todayDate = DateFormat(dateFormat).format(now);
  return todayDate;
}

String getStringLengthText(String value) {
  String? substring;
  if (value.isNotEmpty) {
    if (value.length > 18) {
      substring = value.substring(0, 17);
    } else {
      substring = value;
    }
  }
  return substring ?? '';
}

String getshortStringLengthText({required String value, int size = 15}) {
  String? substring;
  if (value.isNotEmpty) {
    if (value.length > size) {
      substring = value.substring(0, size);
    } else {
      substring = value;
    }
  }
  return substring ?? '';
}
