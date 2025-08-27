import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import '../helper/textstyle.dart';
import 'colors.dart';

class CommonButton extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isIconReq;
  final bool isbgReq;
  final bool isLoading;
  const CommonButton({
    super.key,
    required this.label,
    this.bgColor = AppColors.blackColor,
    required this.onTap,
    this.isIconReq = false,
    this.isbgReq = true,
    this.height = 40,
    this.width = 250,
    this.radius = 15,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isbgReq ? bgColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child:
            isIconReq
                ? Icon(
                  CupertinoIcons.back,
                  color: AppColors.whiteColor,
                  size: 25,
                )
                : Center(
                  child:
                      isLoading
                          ? CommonProgressbar()
                          : Text(
                            label,
                            style: CustomTextStyle.customRaleway(
                              fontSize: 15,
                              color:
                                  isbgReq
                                      ? AppColors.whiteColor
                                      : AppColors.blackColor,
                            ),
                          ),
                ),
      ),
    );
  }
}
