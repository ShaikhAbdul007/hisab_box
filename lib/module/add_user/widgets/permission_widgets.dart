
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class PermissionWidgets extends StatelessWidget {
  final String title;
  final List<String> keys;
  final Map<String, RxBool> permissions;

  const PermissionWidgets({
    super.key,
    required this.title,
    required this.keys,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        title: Text(title),
        children: keys.map((permissionKey) {
          return Obx(() => SwitchListTile(
                title: Text(
                  permissionKey
                      .replaceAll('p_', '')
                      .replaceAll('_', ' ')
                      .capitalizeFirst!,
                ),
                value: permissions[permissionKey]?.value ?? false,
                onChanged: (val) {
                  permissions[permissionKey]?.value = val;
                },
              ));
        }).toList(),
      ),
    );
  }
}
