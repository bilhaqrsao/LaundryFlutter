import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_laundry/app/model/konsumen_model.dart';
import 'package:new_laundry/app/model/service_model.dart';
import 'package:new_laundry/app/modules/login/views/login_view.dart';
import 'package:new_laundry/config/app_endpoint.dart';

class TrasanctionController extends GetxController {
  // State untuk menyimpan jumlah item
  RxInt itemCount = 0.obs;

  // State untuk konsumen
  RxString selectedKonsumenName = RxString('');
  final konsumenList = <Konsumen>[].obs;
  final searchResult = <Konsumen>[].obs;
  final searchText = ''.obs;
  final limit = 10;

  // State untuk layanan
  RxString selectedLayananName = RxString('');
  final layananList = <ServiceModel>[].obs;
  final searchResultLayanan = <ServiceModel>[].obs;
  final searchTextLayanan = ''.obs;

  // State untuk detail transaksi
  final detailTransaksiList = <Map<String, dynamic>>[].obs;

  // Storage
  final box = GetStorage();

  // State untuk loading
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLayanan();
    fetchKonsumen();
    loadStoredData();
  }

  void loadStoredData() {
    var storedDetailTransaksi = box.read<List>('detailTransaksiList');
    if (storedDetailTransaksi != null) {
      detailTransaksiList.assignAll(
        storedDetailTransaksi.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }
  }

  void saveDetailTransaksi() {
    box.write('detailTransaksiList', detailTransaksiList);
  }

  void incrementItem() {
    itemCount.value++;
  }

  void decrementItem() {
    if (itemCount.value > 0) {
      itemCount.value--;
    }
  }

  void saveTransaction() {
    if (detailTransaksiList.isEmpty) {
      Get.snackbar('Error', 'Tidak ada layanan yang ditambahkan');
      return;
    }
    addTransaksi();
  }

  Future<void> fetchLayanan() async {
    try {
      var token = await GetStorage().read('token');
      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.layananEndPoint.getLayanan);
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body)['data'];
        List<ServiceModel> layanans = jsonResponse.map((item) => ServiceModel.fromJson(item)).toList();
        layananList.assignAll(layanans);
        updateSearchResultsLayanan();
      } else {
        throw Exception('Failed to fetch layanan: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch layanan: $e');
    }
  }

  void updateSearchResultsLayanan() {
    if (searchTextLayanan.value.isEmpty) {
      searchResultLayanan.assignAll(layananList);
    } else {
      var query = searchTextLayanan.value.toLowerCase();
      var result = layananList.where((item) => item.nama!.toLowerCase().contains(query)).toList();
      searchResultLayanan.assignAll(result);
    }
  }

  void resetSearchLayanan() {
    searchTextLayanan.value = '';
    updateSearchResultsLayanan();
  }

  void searchLayanan(String value) {
    searchTextLayanan.value = value;
    updateSearchResultsLayanan();
  }

  Future<void> fetchKonsumen() async {
    try {
      var token = await GetStorage().read('token');
      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.konsumenEndPoint.getKonsumen);
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Konsumen> konsumens = jsonResponse.map((item) => Konsumen.fromJson(item)).toList();
        konsumenList.assignAll(konsumens);
        updateSearchKonsumenResults();
      } else {
        throw Exception('Failed to fetch konsumen: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch konsumen: $e');
    }
  }

  void searchKonsumen(String value) {
    searchText.value = value;
    updateSearchKonsumenResults();
  }

  void resetSearchKonsumen() {
    searchText.value = '';
    updateSearchKonsumenResults();
  }

  void updateSearchKonsumenResults() {
    if (searchText.isEmpty) {
      searchResult.assignAll(konsumenList.take(limit));
    } else {
      var query = searchText.toLowerCase();
      var results = konsumenList.where((konsumen) => konsumen.nama.toLowerCase().contains(query)).toList();
      searchResult.assignAll(results);
    }
  }

  Future<void> addTransaksi() async {
    isLoading.value = true;
    try {
      var token = await GetStorage().read('token');
      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var konsumen = konsumenList.firstWhere((konsumen) => konsumen.nama == selectedKonsumenName.value);
      var detailTransaksi = detailTransaksiList.map((item) => {
        'layananId': item['id'],
        'berat': item['jumlah'],
      }).toList();

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.createTransaksi);
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'konsumenId': konsumen.id,
          'detailTransaksi': detailTransaksi,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Transaksi berhasil ditambahkan');
        resetTransaction();
      } else {
        Get.snackbar('Error', 'Failed to add transaksi: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addLayanan(ServiceModel layanan, int jumlah) {
    if (jumlah <= 0) {
      Get.snackbar('Error', 'Jumlah layanan harus lebih dari 0');
      return;
    }
    detailTransaksiList.add({
      'id': layanan.id,
      'nama': layanan.nama,
      'harga': layanan.harga! * jumlah,
      'jumlah': jumlah,
    });
    saveDetailTransaksi();
  }

  void removeLayanan(int index) {
    detailTransaksiList.removeAt(index);
    saveDetailTransaksi();
  }

  void resetTransaction() {
    detailTransaksiList.clear();
    selectedKonsumenName.value = '';
    box.remove('detailTransaksiList');
  }

  @override
  void onClose() {
    konsumenList.clear();
    super.onClose();
  }
}
