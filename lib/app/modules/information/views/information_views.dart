import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_laundry/app/modules/information/controllers/information_controller.dart';
import 'package:intl/intl.dart';
import 'package:draggable_home/draggable_home.dart';

class InformationViews extends GetView<InformationController> {
  final informationController = Get.put(InformationController());
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern('id_ID');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          informationController.fetchTransaksi();
        },
        child: DraggableHome(
          headerExpandedHeight: 0.40,
          title: const Text('Statistics', style: TextStyle(color: Colors.black)),
          headerWidget: _buildHeaderWidget(context),
          body: [
            SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => _buildInfoCard(context, 'Sudah Bayar', 'Rp. ${currencyFormatter.format(informationController.totalPaid.value)}', Colors.blue, 'Selesai')),
                      Obx(() => _buildInfoCard(context, 'Belum Bayar', 'Rp. ${currencyFormatter.format(informationController.totalUnpaid.value)}', Colors.purple, 'belum')),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildTransaksiList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue,
            child: TabBar(
              tabs: [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
          ),
          Container(
            height: 250, // Adjust the height based on your requirement
            child: TabBarView(
              children: [
                _buildChart(context, 'Daily'),
                _buildChart(context, 'Weekly'),
                _buildChart(context, 'Monthly'),
                _buildChart(context, 'Yearly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, String period) {
    return Obx(() {
      if (informationController.isLoading.value) {
        return Center(
          child: SpinKitFadingCircle(
            color: Colors.blue,
            size: 50.0,
          ),
        );
      } else {
        final transactionsByPeriod = informationController.getTransactionsByPeriod(period);
        final paidTransactions = transactionsByPeriod['paid'] ?? {};
        final unpaidTransactions = transactionsByPeriod['unpaid'] ?? {};

        List<BarChartGroupData> barGroups = [];
        Set<String> allDates = {...paidTransactions.keys, ...unpaidTransactions.keys};
        for (var date in allDates) {
          int paid = paidTransactions[date] ?? 0;
          int unpaid = unpaidTransactions[date] ?? 0;
          barGroups.add(
            BarChartGroupData(
              x: DateTime.parse(date).day,
              barRods: [
                BarChartRodData(fromY: 0, toY: paid.toDouble(), color: Colors.blue),
                BarChartRodData(fromY: 0, toY: unpaid.toDouble(), color: Colors.red),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 50,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String weekDay = DateFormat('EEEE').format(DateTime.parse(allDates.elementAt(groupIndex)));
                    return BarTooltipItem(
                      '$weekDay\n${rod.toY.toInt()} transactions',
                      TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      );
                    },
                    reservedSize: 16,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        );
      }
    });
  }

  Widget _buildInfoCard(BuildContext context, String title, String amount, Color color, String statusBayar) {
    return GestureDetector(
      onTap: () {
        informationController.filteredStatusBayar.value = statusBayar;
      },
      child: Card(
        color: color,
        child: Container(
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 4),
              Text(amount, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaksiList() {
    return Obx(
      () {
        List<dynamic> filteredList = informationController.transaksiList;
        if (informationController.filteredStatusBayar.value.isNotEmpty) {
          filteredList = informationController.transaksiList.where((transaksi) {
            return transaksi['statusBayar'] == informationController.filteredStatusBayar.value;
          }).toList();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 10, bottom: 20),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final transaksi = filteredList[index];
            final konsumenName = transaksi['konsumen']['nama'];
            final statusBayar = transaksi['statusBayar'] ?? 'Belum Bayar';
            final statusAmbil = transaksi['statusAmbil'] ?? 'Belum Ambil';
            final date = DateFormat('dd MMMM yyyy').format(DateTime.parse(transaksi['createdAt']));
            final amount = 'Rp. ${currencyFormatter.format(transaksi['total'])}';

            return GestureDetector(
              onTap: () => _showDetailDialog(transaksi),
              child: _buildTransaksiItem(konsumenName, statusBayar, statusAmbil, date, amount),
            );
          },
        );
      },
    );
  }


  Widget _buildTransaksiItem(String konsumenName, String statusBayar, String statusAmbil, String date, String amount) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(konsumenName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Bayar: $statusBayar'),
            Text('Status Ambil: $statusAmbil'),
            Text('Tanggal: $date'),
          ],
        ),
        trailing: Text(amount, style: TextStyle(color: Colors.green)),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> transaksi) {
    final statusBayar = transaksi['statusBayar'];
    final statusAmbil = transaksi['statusAmbil'];

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.blue),
            SizedBox(width: 8),
            Text('Detail Transaksi'),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Konsumen: ${transaksi['konsumen']['nama']}'),
              Text('Total: Rp. ${currencyFormatter.format(transaksi['total'])}'),
              Text('Status Bayar: ${statusBayar ?? 'Belum Bayar'}'),
              Text('Status Ambil: ${statusAmbil ?? 'Belum Ambil'}'),
              SizedBox(height: 10),
              Text('Detail Layanan:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...transaksi['detailTransaksi'].map<Widget>((detail) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${detail['layanan']['nama']} - ${detail['berat']} Kg'),
                    Text('Harga: Rp. ${currencyFormatter.format(detail['total_harga'])}'),
                    SizedBox(height: 5),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          if (statusBayar != 'Selesai')
            TextButton.icon(
              icon: Icon(Icons.check_circle, color: Colors.green),
              label: Text('Konfirmasi Bayar'),
              onPressed: () {
                _showConfirmationDialog(
                  title: 'Konfirmasi Bayar',
                  content: 'Apakah Anda yakin ingin mengonfirmasi pembayaran ini?',
                ).then((confirmed) {
                  if (confirmed) {
                    Get.back(); // Close the detail dialog
                    // Check status again before updating
                    if (transaksi['statusBayar'] != 'Selesai') {
                      informationController.updateStatusBayar(transaksi['id'].toString());
                    }
                  }
                });
              },
            ),
          if (statusAmbil != 'Selesai')
            TextButton.icon(
              icon: Icon(Icons.check_circle_outline, color: Colors.blue),
              label: Text('Konfirmasi Ambil'),
              onPressed: () {
                _showConfirmationDialog(
                  title: 'Konfirmasi Ambil',
                  content: 'Apakah Anda yakin ingin mengonfirmasi pengambilan ini?',
                ).then((confirmed) {
                  if (confirmed) {
                    Get.back(); // Close the detail dialog
                    // Check status again before updating
                    if (transaksi['statusAmbil'] != 'Selesai') {
                      informationController.updateStatusAmbil(transaksi['id'].toString());
                    }
                  }
                });
              },
            ),
          TextButton.icon(
            icon: Icon(Icons.delete, color: Colors.red),
            label: Text('Konfirmasi Hapus'),
            onPressed: () {
              _showConfirmationDialog(
                title: 'Konfirmasi Hapus',
                content: 'Apakah Anda yakin ingin menghapus transaksi ini?',
              ).then((confirmed) {
                if (confirmed) {
                  Get.back(); // Close the detail dialog
                  informationController.deleteTransaksi(transaksi['id'].toString());
                }
              });
            },
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog({required String title, required String content}) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('Ya'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
