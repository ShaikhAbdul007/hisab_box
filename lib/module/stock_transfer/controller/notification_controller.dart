import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../helper/set_format_date.dart';

class NotificationController extends GetxController
    with CacheManager, LocalService {
  RxList<GoDownStockTransferToShopModel> pendingTransfers =
      <GoDownStockTransferToShopModel>[].obs;

  // Variable name same rakha hai, but Supabase ID use hogi
  final userId = SupabaseConfig.auth.currentUser?.id;
  RxBool isTransferLoading = false.obs;
  StreamSubscription? _transferSub;

  @override
  void onInit() {
    listenPendingTransfers(); // 🔔 shop notification
    super.onInit();
  }

  // ==========================================
  // 🔥 FETCH/LISTEN (HIVE + SUPABASE FALLBACK)
  // ==========================================
  void listenPendingTransfers() async {
    if (userId == null) return;

    // 1️⃣ Hive Cache Check
    var localNotifications = LocalService.getPendingTransfers();
    if (localNotifications.isNotEmpty) {
      pendingTransfers.value = localNotifications;
    }

    // 2️⃣ Supabase Fetch (Fallback & Refresh)
    try {
      final response = await SupabaseConfig.from(
        'stock_transfers',
      ).select().eq('user_id', userId!).eq('status', 'pending');

      List<GoDownStockTransferToShopModel> freshList =
          (response as List)
              .map(
                (e) => GoDownStockTransferToShopModel.fromJson(
                  e,
                  e['id'].toString(),
                ),
              )
              .toList();

      pendingTransfers.value = freshList;

      // 3️⃣ Save to Hive
      await LocalService.savePendingTransfers(freshList);
    } catch (e) {
      AppLogger.info(("🚨 Notification Fetch Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }

  // ==========================================
  // 🔥 ACCEPT TRANSFER (RPC TRANSACTION + HIVE SYNC)
  // ==========================================
  Future<void> acceptTransfer(GoDownStockTransferToShopModel transfer) async {
    if (userId == null) return;
    isTransferLoading.value = true;

    try {
      // Supabase RPC use karna transaction ke liye best hai
      // Is function mein Godown -Qty hoga aur Shop +Qty hoga
      await SupabaseConfig.client.rpc(
        'accept_stock_transfer',
        params: {
          'p_transfer_id': transfer.id,
          'p_user_id': userId,
          'p_barcode': transfer.barcode,
          'p_qty': transfer.requestedQty,
          'p_accepted_at': setFormateDate(),
        },
      );

      // 🔥 UPDATE HIVE LOCALLY (Immediate Sync)
      // Notification list se hatao
      pendingTransfers.removeWhere((element) => element.id == transfer.id);
      await LocalService.savePendingTransfers(pendingTransfers);

      // Local Stock Update (Hive)
      // Shop stock badhao
      double currentShopStock =
          LocalService.getLocalStock(transfer.barcode, false) ?? 0;
      await LocalService.updateLocalStock(
        transfer.barcode,
        currentShopStock + transfer.requestedQty,
        false,
      );

      // 🔄 Purane invalidate cache methods
      removePoductModel();
      removeGodownProductList();
      // recalculateInventoryDashboardOnly(); // Iska logic dashboard controller mein handle hoga

      showMessage(message: "✅ Stock received in shop");
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isTransferLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 REJECT TRANSFER (SUPABASE + HIVE SYNC)
  // ==========================================
  Future<void> rejectTransfer(GoDownStockTransferToShopModel transfer) async {
    if (userId == null) return;

    try {
      await SupabaseConfig.from('stock_transfers')
          .update({'status': 'rejected', 'rejectedAt': setFormateDate()})
          .eq('id', transfer.id);

      // Hive Update
      pendingTransfers.removeWhere((element) => element.id == transfer.id);
      await LocalService.savePendingTransfers(pendingTransfers);

      showMessage(message: "❌ Transfer rejected");
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }

  @override
  void onClose() {
    _transferSub?.cancel();
    super.onClose();
  }
}
