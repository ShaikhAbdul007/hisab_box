import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get barcode => text()(); // primary key
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get animalType => text()();

  IntColumn get packetQty => integer().withDefault(const Constant(0))();
  RealColumn get looseQty => real().withDefault(const Constant(0.0))();

  RealColumn get purchasePrice => real()();
  RealColumn get sellPricePacket => real()();
  RealColumn get sellPriceLoose => real().nullable()();

  BoolColumn get isLooseAllowed =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get location => text().nullable()();
  TextColumn get rack => text().nullable()();
  TextColumn get level => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {barcode};
}
