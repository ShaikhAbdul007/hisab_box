import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/module/stock_transfer/controller/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Notification',
      body: Obx(() {
        if (controller.pendingTransfers.isEmpty) {
          return const Center(
            child: CommonNodatafound(message: "No notification found"),
          );
        }
        return ListView.builder(
          itemCount: controller.pendingTransfers.length,
          itemBuilder: (context, index) {
            final transfer = controller.pendingTransfers[index];
            return TransferTile(transfer: transfer, controller: controller);
          },
        );
      }),
    );
  }
}

class TransferTile extends StatelessWidget {
  final GoDownStockTransferToShopModel transfer;
  final NotificationController controller;

  const TransferTile({
    super.key,
    required this.transfer,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transfer.productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("Barcode: ${transfer.barcode}"),
            Text("Requested Qty: ${transfer.requestedQty}"),
            const SizedBox(height: 10),

            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          controller.isTransferLoading.value
                              ? null
                              : () {
                                controller.rejectTransfer(transfer);
                              },
                      child: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          controller.isTransferLoading.value
                              ? null
                              : () {
                                controller.acceptTransfer(transfer);
                              },
                      child:
                          controller.isTransferLoading.value
                              ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text("Accept"),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
