import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/size.dart';

class NointernateConnection extends StatelessWidget {
  const NointernateConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Image.asset('assets/connection.png'),
          setHeight(height: 10),
          CommonButton(
            label: 'Refresh',
            onTap: () async {
              var result = await Connectivity().checkConnectivity();
              if (result.isNotEmpty && result.first != ConnectivityResult.none) {
                try {
                  final response = await InternetAddress.lookup('example.com');
                  if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
                    Get.back();
                  }
                } on SocketException catch (_) {
                  // Internet is not yet available
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
