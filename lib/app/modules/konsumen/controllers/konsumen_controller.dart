import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_laundry/app/modules/login/views/login_view.dart';
import 'package:new_laundry/config/app_endpoint.dart';
import 'dart:convert';
import '../../../model/konsumen_model.dart';

class KonsumenController extends GetxController {
  final count = 0.obs;
  final konsumenList = <Konsumen>[].obs;
  final searchResult = <Konsumen>[].obs;
  final searchText = ''.obs;
  final limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchKonsumen();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> fetchKonsumen() async {
    try {
      var url = Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.konsumenEndPoint.getKonsumen}');
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView);
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Konsumen> konsumens = jsonResponse.map((item) => Konsumen.fromJson(item)).toList();
        konsumenList.assignAll(konsumens); // Assign all fetched items to the list
        updateSearchResults();
      } else {
        Get.snackbar('Error', 'Failed to fetch konsumen');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch konsumen');
    }
  }

  void searchKonsumen(String value) {
    searchText.value = value;
    updateSearchResults();
  }

  void updateSearchResults() {
    if (searchText.isEmpty) {
      searchResult.assignAll(konsumenList.take(limit));
    } else {
      var query = searchText.toLowerCase();
      var results = konsumenList.where((konsumen) => konsumen.nama.toLowerCase().contains(query)).toList();
      searchResult.assignAll(results);
    }
  }

  void loadMore() {
    searchResult.assignAll(konsumenList);
  }

  Future<void> createKonsumen(String name) async {
    try {
      var url = Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.konsumenEndPoint.createKonsumen}');
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView);
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama': name}),
      );

      if (response.statusCode == 201) {
        konsumenList.add(Konsumen.fromJson(jsonDecode(response.body)));
        Get.snackbar('Success', 'Konsumen berhasil dibuat');
        fetchKonsumen(); // Ambil data konsumen terbaru
      } else {
        Get.snackbar('Error', 'Failed to create konsumen. ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create konsumen. Exception: $e');
    }
  }

  void deleteKonsumen(int konsumenId) async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.konsumenEndPoint.deleteKonsumen(konsumenId.toString()));
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView);
      }

      var response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        konsumenList.removeWhere((konsumen) => konsumen.id == konsumenId);
        Get.snackbar('Success', 'Konsumen berhasil dihapus');
        fetchKonsumen(); // Ambil data konsumen terbaru
      } else {
        Get.snackbar('Error', 'Failed to delete konsumen');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete konsumen');
    }
  }

  Future<void> editKonsumen(String id, String newName) async {
    try {
      var url = Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.konsumenEndPoint.updateKonsumen(id)}');
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView);
      }

      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama': newName}),
      );

      if (response.statusCode == 200) {
        var updatedKonsumen = Konsumen.fromJson(jsonDecode(response.body));
        var index = konsumenList.indexWhere((konsumen) => konsumen.id.toString() == id);
        if (index != -1) {
          konsumenList[index] = updatedKonsumen;
        }
        Get.snackbar('Success', 'Konsumen berhasil diperbarui');
        fetchKonsumen(); // Ambil data konsumen terbaru
      } else {
        Get.snackbar('Error', 'Failed to update konsumen');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update konsumen');
    }
  }
}
