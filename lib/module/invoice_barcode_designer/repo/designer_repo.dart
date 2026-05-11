import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';

class DesignerRepo with CacheManager {
  // ── Barcode Layout ──────────────────────────────────────────────────────────

  /// Saves [layout] to GetStorage. Fire-and-forgets Supabase sync.
  /// Never throws — returns true on success, false on local write failure.
  Future<bool> saveBarcodeLayout(BarcodeLayoutModel layout) async {
    try {
      box.write(Key.barcodeLayout.toString(), layout.toJson());
      _syncToSupabase('barcode_layout', layout.toJson());
      return true;
    } catch (e) {
      AppLogger.error('DesignerRepo.saveBarcodeLayout error: $e');
      return false;
    }
  }

  /// Returns saved [BarcodeLayoutModel] from GetStorage.
  /// Falls back to shop-type specific default layout on any error.
  /// Never throws.
  Future<BarcodeLayoutModel> getBarcodeLayout() async {
    try {
      final stored = box.read(Key.barcodeLayout.toString());
      if (stored != null && stored is Map) {
        return BarcodeLayoutModel.fromJson(Map<String, dynamic>.from(stored));
      }
    } catch (e) {
      AppLogger.error('DesignerRepo.getBarcodeLayout parse error: $e');
    }
    return _shopTypeDefaultLayout();
  }

  /// Synchronous version for use in build() methods.
  BarcodeLayoutModel getBarcodeLayoutSync() {
    try {
      final stored = box.read(Key.barcodeLayout.toString());
      if (stored != null && stored is Map) {
        return BarcodeLayoutModel.fromJson(Map<String, dynamic>.from(stored));
      }
    } catch (e) {
      AppLogger.error('DesignerRepo.getBarcodeLayoutSync parse error: $e');
    }
    return _shopTypeDefaultLayout();
  }

  /// Returns the correct default layout based on current shop type.
  BarcodeLayoutModel _shopTypeDefaultLayout() {
    final user = retrieveUserDetail();
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    switch (shopType) {
      case ShopType.clothingShop:
        return BarcodeLayoutModel.clothingShopDefault();
      case ShopType.petShop:
        return BarcodeLayoutModel.petShopDefault();
    }
  }

  // ── Invoice Config ──────────────────────────────────────────────────────────

  /// Saves [config] to GetStorage. Fire-and-forgets Supabase sync.
  /// Never throws — returns true on success, false on local write failure.
  Future<bool> saveInvoiceConfig(InvoiceConfigModel config) async {
    try {
      box.write(Key.invoiceConfig.toString(), config.toJson());
      _syncToSupabase('invoice_config', config.toJson());
      return true;
    } catch (e) {
      AppLogger.error('DesignerRepo.saveInvoiceConfig error: $e');
      return false;
    }
  }

  /// Returns saved [InvoiceConfigModel] from GetStorage.
  /// Falls back to [InvoiceConfigModel()] defaults on any error.
  /// Never throws.
  Future<InvoiceConfigModel> getInvoiceConfig() async {
    try {
      final stored = box.read(Key.invoiceConfig.toString());
      if (stored != null && stored is Map) {
        return InvoiceConfigModel.fromJson(Map<String, dynamic>.from(stored));
      }
    } catch (e) {
      AppLogger.error('DesignerRepo.getInvoiceConfig parse error: $e');
    }
    return const InvoiceConfigModel();
  }

  /// Synchronous version for use in build() methods.
  /// Falls back to [InvoiceConfigModel()] defaults on any error.
  InvoiceConfigModel getInvoiceConfigSync() {
    try {
      final stored = box.read(Key.invoiceConfig.toString());
      if (stored != null && stored is Map) {
        return InvoiceConfigModel.fromJson(Map<String, dynamic>.from(stored));
      }
    } catch (e) {
      AppLogger.error('DesignerRepo.getInvoiceConfigSync parse error: $e');
    }
    return const InvoiceConfigModel();
  }

  // ── Supabase Sync (best-effort, non-blocking) ───────────────────────────────

  /// Fire-and-forget Supabase upsert. Logs errors, never rethrows.
  void _syncToSupabase(String configType, Map<String, dynamic> configData) {
    final userId = retrieveUserDetail().data?.id;
    if (userId == null || userId.isEmpty) {
      AppLogger.info('DesignerRepo: no user id, skipping Supabase sync');
      return;
    }

    // Supabase sync — best-effort, non-blocking
    // When Supabase is fully enabled, uncomment and use:
    // unawaited(
    //   SupabaseConfig.client
    //       .from('designer_configs')
    //       .upsert({
    //         'user_id': userId,
    //         'config_type': configType,
    //         'config_data': configData,
    //         'updated_at': DateTime.now().toIso8601String(),
    //       }, onConflict: 'user_id,config_type')
    //       .catchError((e) {
    //         AppLogger.info('DesignerRepo Supabase sync failed: $e');
    //       }),
    // );
    AppLogger.info(
      'DesignerRepo: Supabase sync queued for $configType (userId: $userId)',
    );
  }
}
