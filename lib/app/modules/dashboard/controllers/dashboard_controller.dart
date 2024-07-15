import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:new_laundry/app/modules/login/views/login_view.dart';
import 'package:new_laundry/config/app_endpoint.dart';
import 'package:new_laundry/config/authservice.dart';
import 'package:http/http.dart' as http;

class DashboardController extends GetxController {
  final count = 0.obs;
  var isShow = false.obs;
  var userData = {}.obs;
  var totalRupiah = ''.obs;
  var transaksiList = <dynamic>[].obs;
  var totalSelesai = 0.obs;
  var totalBelumBayar = 0.obs;
  var totalSelesaiToday = 0.obs;
  var totalBelumBayarToday = 0.obs;
  var percentSelesai = 0.0.obs;
  var percentBelumBayar = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    userData.value = GetStorage().read('userData') ?? {};
    fetchTransaksi();
    fetchTotalRupiah();
  }

  void logout() async {
    try {
      await AuthService().logout();
      GetStorage().remove('token');
      GetStorage().remove('userData');
      Get.offAll(LoginView());
    } catch (e) {
      throw Exception('Logout failed');
    }
  }

  void fetchTransaksi() async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.getTransaksi);
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView());
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Sort transaksiList by createdAt descending
        List<dynamic> sortedTransaksiList = List.from(jsonResponse);
        sortedTransaksiList.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

        var today = DateTime.now();
        var limitedList = sortedTransaksiList.where((transaksi) {
          var createdAt = DateTime.parse(transaksi['createdAt']);
          return createdAt.year == today.year && createdAt.month == today.month && createdAt.day == today.day;
        }).take(8).toList();

        transaksiList.assignAll(limitedList);

        // Calculate totalSelesai and totalBelumBayar
        int selesai = 0;
        int belumBayar = 0;
        int selesaiToday = 0;
        int belumBayarToday = 0;

        for (var transaksi in sortedTransaksiList) {
          var createdAt = DateTime.parse(transaksi['createdAt']);
          var isToday = createdAt.year == today.year && createdAt.month == today.month && createdAt.day == today.day;

          if (transaksi['statusBayar'] == 'Selesai') {
            selesai += (transaksi['total'] as num).toInt();
            if (isToday) {
              selesaiToday += (transaksi['total'] as num).toInt();
            }
          } else {
            belumBayar += (transaksi['total'] as num).toInt();
            if (isToday) {
              belumBayarToday += (transaksi['total'] as num).toInt();
            }
          }
        }

        totalSelesai.value = selesai;
        totalBelumBayar.value = belumBayar;
        totalSelesaiToday.value = selesaiToday;
        totalBelumBayarToday.value = belumBayarToday;

        int totalToday = selesaiToday + belumBayarToday;
        if (totalToday > 0) {
          percentSelesai.value = (selesaiToday / totalToday) * 100;
          percentBelumBayar.value = (belumBayarToday / totalToday) * 100;
        } else {
          percentSelesai.value = 0;
          percentBelumBayar.value = 0;
        }

      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Failed to get transaksi';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Failed to get transaksi');
    }
  }


  void fetchTotalRupiah() async {
    try {
      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.totalRupiah);
      var token = await GetStorage().read('token');

      if (token == null) {
        Get.to(LoginView());
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        totalRupiah.value = jsonResponse['totalRupiah'];
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Failed to get total rupiah';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Failed to get total rupiah');
    }
  }

  String formatRupiah(int number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void showHide() {
    isShow.value = !isShow.value;
  }
}
