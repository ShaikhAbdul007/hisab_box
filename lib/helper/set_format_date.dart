import 'package:intl/intl.dart';

String setFormateDate([String dateFormat = 'dd-MM-yyyy']) {
  final now = DateTime.now();
  final todayDate = DateFormat(dateFormat).format(now);
  return todayDate;
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
  if (dateStr.isEmpty) return DateTime.now().toIso8601String().split('T')[0];

  try {
    // 1. Pehle readable string ko DateTime object mein badlo
    // Aapka UI format 'dd-MM-yyyy' hai toh wahi use karein
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime parsedDate = inputFormat.parse(dateStr);

    // 2. Ab usey DB format (yyyy-MM-dd) mein convert karo
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  } catch (e) {
    print("🚨 Parsing Error: $e. Input was: $dateStr");

    // Agar parsing fail ho (e.g. already ISO format ho), toh try DateTime.parse
    try {
      return DateTime.parse(dateStr).toIso8601String().split('T')[0];
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
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
  if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
    return '--/--/----'; // Agar date na ho toh crash nahi hoga
  }

  try {
    // String ko DateTime mein badlo
    DateTime dateTime = DateTime.parse(dateStr);

    // dd-mm-yyyy format mein set karo
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();

    return "$day-$month-$year";
  } catch (e) {
    return dateStr; // Agar parse fail ho jaye toh original string hi de do
  }
}
