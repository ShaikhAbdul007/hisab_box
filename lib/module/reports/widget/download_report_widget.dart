import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_radio_button.dart';
import '../../../common_widget/size.dart';

class DownloadReportWidget extends StatelessWidget {
  final List<String> reportLabel;
  final int groupValue;
  final Function(int?)? onChanged;
  final void Function() reportDownloadOnTap;
  final bool reportDownloadButtonEnable;
  final bool isLoading;
  const DownloadReportWidget({
    super.key,
    required this.groupValue,
    required this.reportLabel,
    this.onChanged,
    required this.reportDownloadButtonEnable,
    required this.reportDownloadOnTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250.h,
          width: 500.w,
          child: ListView.builder(
            itemCount: reportLabel.length,
            itemBuilder: (context, index) {
              return CommonRadioButton(
                radioValue: index,
                label: reportLabel[index],
                groupValue: groupValue,
                onChanged: onChanged,
              );
            },
          ),
        ),
        if (reportDownloadButtonEnable == true) ...{
          setHeight(height: 10),
          CommonButton(
            isLoading: isLoading,
            label: 'Download',
            onTap: reportDownloadOnTap,
          ),
        },
        setHeight(height: 30),
      ],
    );
  }
}
