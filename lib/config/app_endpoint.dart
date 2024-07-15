class ApiEndPoint {
  static final String baseUrl = 'http://localhost:3000/';
  static _AuthEndPoint authEndPoint = _AuthEndPoint();
  static _UserEndPoint userEndPoint = _UserEndPoint();
  static _LayananEndPoint layananEndPoint = _LayananEndPoint();
  static _KonsumenEndPoint konsumenEndPoint = _KonsumenEndPoint();
  static _TransaksiEndPoint transaksiEndPoint = _TransaksiEndPoint(); // Added this line
}

class _AuthEndPoint {
  final String register = 'auth/Register';
  final String login = 'auth/login';
  final String logout = 'auth/logout';
}

class _UserEndPoint {
  final String getUser = 'users/';
  final String createUser = 'users/';
  String detailUser(String id) => 'users/$id';
  String updateUser(String id) => 'users/$id';
  String deleteUser(String id) => 'users/$id';
}

class _LayananEndPoint {
  final String getLayanan = 'layanan/';
  final String createLayanan = 'layanan/';
  String detailLayanan(String id) => 'layanan/$id';
  String updateLayanan(String id) => 'layanan/$id';
  String deleteLayanan(String id) => 'layanan/$id';
}

class _KonsumenEndPoint {
  final String getKonsumen = 'konsumen/';
  final String createKonsumen = 'konsumen/';
  String detailKonsumen(String id) => 'konsumen/$id';
  String updateKonsumen(String id) => 'konsumen/$id';
  String deleteKonsumen(String id) => 'konsumen/$id';
}

class _TransaksiEndPoint {
  final String getTransaksi = 'transaksi/';
  final String createTransaksi = 'transaksi/';
  final String totalRupiah = 'transaksi/detail/totalRupiah';
  String detailTransaksi(String id) => 'transaksi/$id';
  String updateTransaksi(String id) => 'transaksi/$id';
  String deleteTransaksi(String id) => 'transaksi/$id';
  String updateStatusAmbil(String id) => 'transaksi/status-ambil/$id';
  String updateStatusBayar(String id) => 'transaksi/status-bayar/$id';
}
