import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/colors.dart';

Future<String> customDatePicker({
  required BuildContext context,
  required DateTime selectedDate,
  required RxString controller,
  DateTime? firstDate,
  String dateFormat = 'dd-MM-yyyy',
  void Function()? onDatePicked,
  final String? puchinout,
  DateTime? lastDate,
}) async {
  DateTime initialDatePickerDate;

  try {
    if (controller.value.isNotEmpty) {
      DateTime parsed = DateFormat(dateFormat).parse(controller.value);

      // Check: Kya parsed date firstDate se pehle toh nahi?
      DateTime limit = firstDate ?? DateTime(1990);
      if (parsed.isBefore(limit)) {
        initialDatePickerDate = selectedDate;
      } else {
        initialDatePickerDate = parsed;
      }
    } else {
      initialDatePickerDate = selectedDate;
    }
  } catch (e) {
    // Agar parsing fail ho jaye (format mismatch)
    initialDatePickerDate = selectedDate;
  }

  // Safety Check for lastDate: initialDate kabhi lastDate ke baad nahi ho sakti
  DateTime effectiveLastDate = lastDate ?? DateTime(2100);
  if (initialDatePickerDate.isAfter(effectiveLastDate)) {
    initialDatePickerDate = effectiveLastDate;
  }

  DateTime? pickedDate = await showDatePicker(
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.grey.shade50,
            onPrimary: AppColors.blackColor,
            onSurface: AppColors.blackColor,
            onSurfaceVariant: AppColors.whiteColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.redColor),
          ),
        ),
        child: child!,
      );
    },
    context: context,
    initialDate: initialDatePickerDate, // Use our safe date
    firstDate: firstDate ?? DateTime(1990),
    lastDate: effectiveLastDate,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );

  if (pickedDate != null) {
    String formatDate = DateFormat(dateFormat).format(pickedDate);
    controller.value = formatDate;
    if (onDatePicked != null) {
      onDatePicked();
    }
    return controller.value;
  } else {
    return '';
  }
}
