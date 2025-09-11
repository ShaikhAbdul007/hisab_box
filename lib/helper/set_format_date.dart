import 'package:intl/intl.dart';

String setFormateDate() {
  final now = DateTime.now();
  final todayDate = DateFormat('dd-MM-yyyy').format(now);
  return todayDate;
}

String getStringLengthText(String value) {
  String? substring;
  if (value.isNotEmpty) {
    if (value.length > 15) {
      substring = value.substring(0, 14);
    } else {
      substring = value;
    }
  }
  return substring ?? '';
}
