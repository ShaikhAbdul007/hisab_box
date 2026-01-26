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
  DateTime tempDate = DateFormat(dateFormat).parse(controller.value);
  DateTime? pickedDate = await showDatePicker(
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.grey.shade50, // header background color
            onPrimary: AppColors.blackColor, // header text color
            onSurface: AppColors.blackColor,
            onSurfaceVariant: AppColors.whiteColor, // body text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.redColor, // button text color
            ),
          ),
        ),
        child: child!,
      );
    },
    context: context,
    initialDate: controller.value.isNotEmpty ? tempDate : selectedDate,
    firstDate: firstDate ?? DateTime(1990),
    lastDate: lastDate ?? selectedDate,
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
