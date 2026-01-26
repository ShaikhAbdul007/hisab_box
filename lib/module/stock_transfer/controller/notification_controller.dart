import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import '../../../helper/set_format_date.dart';

class NotificationController extends GetxController with CacheManager {
  RxList<GoDownStockTransferToShopModel> pendingTransfers =
      <GoDownStockTransferToShopModel>[].obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isTransferLoading = false.obs;
  StreamSubscription? _transferSub;

  @override
  void onInit() {
    listenPendingTransfers(); // 🔔 shop notification
    super.onInit();
  }

  void listenPendingTransfers() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _transferSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('stockTransfers')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          pendingTransfers.value =
              snapshot.docs
                  .map(
                    (e) =>
                        GoDownStockTransferToShopModel.fromJson(e.data(), e.id),
                  )
                  .toList();
        });
  }

  Future<void> acceptTransfer(GoDownStockTransferToShopModel transfer) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isTransferLoading.value = true;

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final transferRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('stockTransfers')
            .doc(transfer.id);

        final snap = await tx.get(transferRef);
        if (!snap.exists) return;

        final data = snap.data()!;
        if (data['status'] != 'pending') return;

        final int qty = data['requestedQty'];
        final String barcode = data['barcode'];

        final godownRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('godownProducts')
            .doc(barcode);

        final shopRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .doc(barcode);

        final godownSnap = await tx.get(godownRef);
        final int godownQty = (godownSnap['quantity'] ?? 0);

        if (godownQty < qty) {
          throw Exception("Godown stock insufficient");
        }

        tx.update(godownRef, {
          'quantity': FieldValue.increment(-qty),
          'updatedDate': setFormateDate(),
        });

        tx.set(shopRef, {
          'quantity': FieldValue.increment(qty),
          'location': 'shop',
          'isActive': true,
          'updatedDate': setFormateDate(),
        }, SetOptions(merge: true));

        tx.update(transferRef, {
          'status': 'accepted',
          'acceptedAt': setFormateDate(),
        });
      });

      // 🔥 invalidate cache (intentional)
      removePoductModel();
      removeGodownProductList();
      recalculateInventoryDashboardOnly();
      showMessage(message: "✅ Stock received in shop");
    } catch (e) {
      showMessage(message: "❌ ${e.toString()}");
    } finally {
      isTransferLoading.value = false;
    }
  }

  Future<void> rejectTransfer(GoDownStockTransferToShopModel transfer) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('stockTransfers')
        .doc(transfer.id)
        .update({'status': 'rejected', 'rejectedAt': setFormateDate()});

    showMessage(message: "❌ Transfer rejected");
  }

  @override
  void onClose() {
    _transferSub?.cancel();
    super.onClose();
  }
}
