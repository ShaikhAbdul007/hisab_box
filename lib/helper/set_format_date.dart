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
  try {
    // Agar date "01-02-2026" ya "01/02/2026" format mein hai
    // Toh usey '-' ya '/' se split karo
    List<String> parts =
        dateStr.contains('-') ? dateStr.split('-') : dateStr.split('/');

    if (parts.length == 3) {
      String day = parts[0].padLeft(2, '0');
      String month = parts[1].padLeft(2, '0');
      String year = parts[2];

      // Agar year pehle likha hai (YYYY-MM-DD) toh parts change karlo
      if (year.length != 4) {
        // Agar pehla part year hai
        return dateStr; // Pehle se sahi format mein hai
      }

      // Database ke liye YYYY-MM-DD banakar return karo
      return "$year-$month-$day";
    }

    // Agar split nahi hua toh simple parse try karo
    DateTime parsed = DateTime.parse(dateStr);
    return "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
  } catch (e) {
    print("Parsing Error: $e");
    // Agar sab fail ho jaye toh aaj ki date bhej do backup ke liye
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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
