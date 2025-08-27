import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

customDatePicker({
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
    return null;
  }
}
