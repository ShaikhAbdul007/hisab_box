import 'package:intl/intl.dart';

String setFormateDate([String dateFormat = 'dd-MM-yyyy']) {
  final now = DateTime.now();
  final todayDate = DateFormat(dateFormat).format(now);
  return todayDate;
}

DateTime? parseAppDate(String? value) {
  if (value == null) return null;
  final input = value.trim();
  if (input.isEmpty) return null;

  try {
    return DateFormat('dd-MM-yyyy').parseStrict(input);
  } catch (_) {}

  try {
    return DateFormat('yyyy-MM-dd').parseStrict(input);
  } catch (_) {}

  try {
    return DateTime.parse(input);
  } catch (_) {}

  return null;
}

String setFormatForDb(String dateStr) {
  return formatDateForDB(dateStr);
}

String formatDateForUi(
  String? dateStr, {
  String emptyFallback = '--/--/----',
}) {
  if (dateStr == null || dateStr.trim().isEmpty || dateStr == 'null') {
    return emptyFallback;
  }

  final parsed = parseAppDate(dateStr);
  if (parsed == null) return dateStr;
  return DateFormat('dd-MM-yyyy').format(parsed);
}

String setDateFormated(
  String dateString, {
  String fromFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ',
  String toFormat = 'dd-MM-yyyy',
}) {
  try {
    final DateTime parsedDate = DateFormat(fromFormat).parse(dateString);
    final String formattedDate = DateFormat(toFormat).format(parsedDate);
    return formattedDate;
  } catch (e) {
    return dateString; // Return the original string if parsing fails
  }
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

String formatDateForDB(String dateStr) {
  final value = dateStr.trim();
  if (value.isEmpty) return DateTime.now().toIso8601String().split('T')[0];

  final parsed = parseAppDate(value);
  if (parsed == null) {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
  return DateFormat('yyyy-MM-dd').format(parsed);
}

String formatDateForRpc(String dateStr) {
  final value = dateStr.trim();
  if (value.isEmpty) return setFormateDate();
  final parsed = parseAppDate(value);
  if (parsed == null) return setFormateDate();
  return DateFormat('dd-MM-yyyy').format(parsed);
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

String formatDate(String? dateStr) {
  return formatDateForUi(dateStr);
}
