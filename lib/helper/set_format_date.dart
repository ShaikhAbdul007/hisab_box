import 'package:intl/intl.dart';

String setFormateDate([String dateFormat = 'dd-MM-yyyy']) {
  final now = DateTime.now();
  final todayDate = DateFormat(dateFormat).format(now);
  return todayDate;
}

String getFormattedDate(String date) {
  final parsedDate = DateFormat('dd-MM-yyyy').parseStrict(date);
  return DateFormat('yyyy-MM-dd').format(parsedDate);
}

String formatDateTime(
  String dateString, {
  bool showDate = true,
  bool showTime = false,
  String dateFormat = 'dd-MM-yyyy',
  String timeFormat = 'hh:mm:ss a',
}) {
  try {
    final DateTime parsedDate = DateTime.parse(dateString); // ISO SAFE

    final List<String> parts = [];

    if (showDate) {
      parts.add(DateFormat(dateFormat).format(parsedDate));
    }

    if (showTime) {
      parts.add(DateFormat(timeFormat).format(parsedDate));
    }

    return parts.join(' ');
  } catch (e) {
    return dateString; // fallback (never crash UI)
  }
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

String? parseAppDate(String? value) {
  if (value == null) return null;

  final input = value.trim();

  if (input.isEmpty) return null;

  final parsedDate = DateFormat('dd-MM-yyyy').parseStrict(input);

  return DateFormat('yyyy-MM-dd').format(parsedDate);
}
