import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_laundry/app/modules/login/views/login_view.dart';
import 'package:new_laundry/app/model/service_model.dart';
import 'package:new_laundry/config/app_endpoint.dart';

class ServiceController extends GetxController {
  final layananList = <ServiceModel>[].obs;
  final searchResult = <ServiceModel>[].obs;
  final searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLayanan();
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
        updateSearchResults();
      } else {
        throw Exception('Failed to fetch layanan: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch layanan: $e');
    }
  }

  void updateSearchResults() {
    if (searchText.value.isEmpty) {
      searchResult.assignAll(layananList);
    } else {
      var query = searchText.value.toLowerCase();
      var result = layananList.where((item) => item.nama!.toLowerCase().contains(query)).toList();
      searchResult.assignAll(result);
    }
  }

  void searchLayanan(String value) {
    searchText.value = value;
    updateSearchResults();
  }

  Future<void> deleteLayanan(int layananId) async {
    try {
      var token = await GetStorage().read('token');
      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.layananEndPoint.deleteLayanan(layananId.toString()));
      var response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        layananList.removeWhere((item) => item.id == layananId);
        updateSearchResults();
        Get.snackbar('Success', 'Layanan berhasil dihapus');
      } else {
        throw Exception('Failed to delete layanan: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete layanan: $e');
    }
  }

  Future<void> addLayanan(String nama, double harga, int durasi) async {
    try {
      var token = await GetStorage().read('token');
      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.layananEndPoint.createLayanan);
      var body = jsonEncode({
        'nama': nama,
        'harga': harga,
        'durasi': durasi,
      });

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        var newLayanan = ServiceModel.fromJson(jsonDecode(response.body));
        layananList.add(newLayanan);
        Get.back();
        Get.snackbar('Success', 'Layanan berhasil ditambahkan');
      } else {
        throw Exception('Failed to add layanan: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add layanan: $e');
    }
  }

  Future<void> editLayanan(int layananId, String newName, int newHarga, int newDurasi) async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.layananEndPoint.updateLayanan(layananId.toString()));
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(() => LoginView());
        return;
      }

      var body = jsonEncode({
        'nama': newName,
        'harga': newHarga,
        'durasi': newDurasi,
      });

      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var updatedLayanan = ServiceModel.fromJson(jsonDecode(response.body));
        var index = layananList.indexWhere((layanan) => layanan.id == layananId);
        if (index != -1) {
          layananList[index] = updatedLayanan;
        }
        fetchLayanan(); // Update search results after edit
        Get.snackbar('Success', 'Layanan berhasil diperbarui');
        Get.back();
      } else {
        throw Exception('Failed to update layanan');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
