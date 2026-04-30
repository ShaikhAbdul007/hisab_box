class ApiEndPoint {
  // ---------------- BASE URL ----------------
  static const String baseUrl = "https://hisab-box.softwaresnip.com/";
  static const String servicePath = "api/v1/";
  static const String fullBaseUrl = baseUrl + servicePath;

  // ---------------- HEADERS ----------------
  static const String contentType = 'application/json; charset=UTF-8';
  static const String authorization = "Authorization";
  static const String accept = "application/json";

  // ---------------- AUTH ----------------
  static const String registerUser = "auth/registeruser";
  static const String sendOtp = "auth/send-otp";
  static const String verifyOtp = "auth/verify-otp";
  static const String getProfile = "auth/profile";
  static const String updateProfile = "auth/profile";
  static const String logout = "auth/logout";

  // ---------------- DASHBOARD ----------------
  static const String dashboard = "shop/dashboard";

  // ---------------- CATEGORY ----------------
  static const String getCategories = "shop/categories";
  static const String createCategory = "shop/categories";
  static const String deleteCategory = "shop/categories"; // + id

  // ---------------- ANIMAL CATEGORY ----------------
  static const String getAnimalCategories = "shop/animal-categories";
  static const String createAnimalCategory = "shop/animal-categories";
  static const String deleteAnimalCategory = "shop/animal-categories"; // + id

  // ---------------- PRODUCTS ----------------
  static const String getProducts = "shop/products";
  static const String addProduct = "shop/products/add";
  static const String addLoosedProduct =
      "shop/products/convert-packet-to-loose";
  static const String updateLoosedProduct = "shop/products/loose-stock";
  static const String getProductByBarcode =
      "shop/products/barcode"; // + barcode

  // ---------------- SALES ----------------
  static const String sellProduct = "shop/sell";
  static const String sell = "sales";

  // ---------------- BANK ----------------
  static const String getBankDetails = "shop/bank-details";
  static const String createBankDetails = "shop/bank-details";

  // ---------------- INVENTORY ----------------
  static const String transferGodownToShop = "shop/transfer-godown-to-shop";

  // ---------------- STOCK REPORT ----------------
  static const String nearExpiry =
      "shop/stock/near-expiry"; // ?days=&page=&limit=

  static const String outOfStock = "shop/stock/out-of-stock"; // ?page=&limit=

  static const String addEmployees = "employees/add"; //
  static const String getEmployees = "employees"; //
  static const String updateEmployeesPermissions = "permissions"; //

  // ---------------- REPORTS ----------------
  static const String salesReport =
      "shop/reports/sales"; // ?start_date=&end_date=&page=&limit=
  static const String dailyOverview = "reports/daily-overview";
  static const String reportsTopProductsGraph = "reports/top-products/graph";
  static const String reportsTopProductsList = "reports/top-products/list";
  static const String addCustomer = "customer/customers";
  static const String getAllCustomer = "customer/customers";
  static const String getCustomerMobileNumber =
      "customer/customers/mobile/"; //add mobile number
  // ---------------- User Role ----------------

  static const String getAllUserRoles =
      "roles"; // ?start_date=&end_date=&page=&limit=
  static const String createUserRoles =
      "roles"; // ?start_date=&end_date=&page=&limit=
  static const String updateUserRoles = "roles"; //pass role id for update
  static const String deleteUserRoles = "roles"; //pass role id for delete
}
