import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_laundry/app/model/list_detailTransaksi.dart';
import 'package:new_laundry/app/modules/login/views/login_view.dart';
import 'package:new_laundry/config/app_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InformationController extends GetxController {
  var isLoading = true.obs;
  var transaksiList = <dynamic>[].obs;
  var detailTransaksi = <DetailTransaksi>[].obs;
  var statusBayar = ''.obs;
  var statusAmbil = ''.obs;
  var paidTransactions = <String, int>{}.obs;
  var unpaidTransactions = <String, int>{}.obs;
  var totalPaid = 0.obs;
  var totalUnpaid = 0.obs;
  var periodTotalPaid = 0.obs;
  var periodTotalUnpaid = 0.obs;
  var filteredStatusBayar = ''.obs;
  var filteredStatusAmbil = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchTransaksi();
  }

  Future<String?> getToken() async {
    return await GetStorage().read('token');
  }

  Future<void> fetchTransaksi() async {
    try {
      isLoading(true);
      var token = await getToken();
      if (token == null) {
        Get.to(LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.getTransaksi);
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> sortedTransaksiList = List.from(jsonResponse);
        sortedTransaksiList.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

        transaksiList.assignAll(sortedTransaksiList);

        prepareChartData();
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Gagal mengambil transaksi';
        throw Exception(error);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void prepareChartData() {
    Map<String, int> paid = {};
    Map<String, int> unpaid = {};
    int paidTotal = 0;
    int unpaidTotal = 0;

    transaksiList.forEach((transaksi) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(transaksi['createdAt']));
      if (transaksi['statusBayar'] == 'belum') {
        unpaid.update(date, (value) => value + 1, ifAbsent: () => 1);
        unpaidTotal += (transaksi['total'] as int);
      } else {
        paid.update(date, (value) => value + 1, ifAbsent: () => 1);
        paidTotal += (transaksi['total'] as int);
      }
    });

    paidTransactions.assignAll(paid);
    unpaidTransactions.assignAll(unpaid);
    totalPaid.value = paidTotal;
    totalUnpaid.value = unpaidTotal;
  }

  Map<String, Map<String, int>> getTransactionsByPeriod(String period) {
    DateTime now = DateTime.now();
    Map<String, int> paid = {};
    Map<String, int> unpaid = {};
    int paidTotal = 0;
    int unpaidTotal = 0;

    transaksiList.forEach((transaksi) {
      DateTime createdAt = DateTime.parse(transaksi['createdAt']);
      bool isInPeriod = false;

      switch (period) {
        case 'Daily':
          isInPeriod = createdAt.day == now.day && createdAt.month == now.month && createdAt.year == now.year;
          break;
        case 'Weekly':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
          isInPeriod = createdAt.isAfter(startOfWeek) && createdAt.isBefore(endOfWeek);
          break;
        case 'Monthly':
          isInPeriod = createdAt.month == now.month && createdAt.year == now.year;
          break;
        case 'Yearly':
          isInPeriod = createdAt.year == now.year;
          break;
      }

      if (isInPeriod) {
        String date = DateFormat('yyyy-MM-dd').format(createdAt);
        if (transaksi['statusBayar'] == null) {
          unpaid.update(date, (value) => value + 1, ifAbsent: () => 1);
          unpaidTotal += (transaksi['total'] as int);
        } else {
          paid.update(date, (value) => value + 1, ifAbsent: () => 1);
          paidTotal += (transaksi['total'] as int);
        }
      }
    });

    periodTotalPaid.value = paidTotal;
    periodTotalUnpaid.value = unpaidTotal;

    return {
      'paid': paid,
      'unpaid': unpaid,
    };
  }

  Future<void> deleteTransaksi(String transaksiId) async {
    try {
      var token = await getToken();
      if (token == null) {
        Get.to(LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.deleteTransaksi(transaksiId));
      var response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var deletedTransaksi = jsonDecode(response.body);
        transaksiList.removeWhere((item) => item['id'] == deletedTransaksi['id']);
        showSuccessSnackbar('Transaksi berhasil dihapus');
        prepareChartData();
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Gagal menghapus transaksi';
        throw Exception(error);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<void> fetchDetailTransaksi(String transaksiId) async {
    try {
      var token = await getToken();
      if (token == null) {
        Get.to(LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.detailTransaksi(transaksiId));
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        detailTransaksi.clear();

        if (jsonResponse['detailTransaksi'] != null) {
          var detailTransaksiList = DetailTransaksi.fromJsonList(jsonResponse['detailTransaksi']);
          detailTransaksi.assignAll(detailTransaksiList);
        }
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Gagal mendapatkan detail transaksi';
        throw Exception(error);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<void> updateStatusAmbil(String transaksiId) async {
    try {
      var token = await getToken();
      if (token == null) {
        Get.to(LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.updateStatusAmbil(transaksiId));
      var response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        fetchDetailTransaksi(transaksiId);
        fetchTransaksi();
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Gagal mengupdate status Ambil';
        throw Exception(error);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<void> updateStatusBayar(String transaksiId) async {
    try {
      var token = await getToken();
      if (token == null) {
        Get.to(LoginView());
        return;
      }

      var url = Uri.parse(ApiEndPoint.baseUrl + ApiEndPoint.transaksiEndPoint.updateStatusBayar(transaksiId));
      var response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        fetchDetailTransaksi(transaksiId);
        fetchTransaksi();
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Gagal mengupdate status Bayar';
        throw Exception(error);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void logout() {
    GetStorage().remove('token');
    Get.off(LoginView());
  }
}
