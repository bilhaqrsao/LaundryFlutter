import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_laundry/app/modules/information/views/information_views.dart';
import 'package:new_laundry/app/modules/konsumen/views/konsumen_view.dart';
import 'package:new_laundry/app/modules/service/views/service_view.dart';
import 'package:new_laundry/config/app_asset.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final DashboardController dashboardC = Get.put(DashboardController());

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          dashboardC.fetchTransaksi();
          dashboardC.fetchTotalRupiah();
        },
        child: DraggableHome(
          headerExpandedHeight: 0.40,
          title: const Text('Daftar Transaksi', style: TextStyle(color: Colors.black)),
          headerWidget: headerWidget(),
          body: [
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Report Today', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.pink[50],
                                          child: Icon(Icons.widgets, color: Colors.pink),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text('${dashboardC.percentBelumBayar.toStringAsFixed(1)}%', style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text('Belum Bayar', style: GoogleFonts.poppins(color: Colors.grey)),
                                    SizedBox(height: 5),
                                    Text('${dashboardC.formatRupiah(dashboardC.totalBelumBayarToday.value)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue[50],
                                          child: Icon(Icons.widgets, color: Colors.blue),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text('${dashboardC.percentSelesai.toStringAsFixed(1)}%', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text('Sudah Bayar', style: GoogleFonts.poppins(color: Colors.grey)),
                                    SizedBox(height: 5),
                                    Text('${dashboardC.formatRupiah(dashboardC.totalSelesaiToday.value)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (dashboardC.transaksiList.isEmpty)
                  const Center(
                    child: Text('Tidak ada transaksi'),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardC.transaksiList.length,
                    itemBuilder: (context, index) {
                      var transaksi = dashboardC.transaksiList[index];
                      var konsumen = transaksi['konsumen']['nama'];
                      var createdAt = DateTime.parse(transaksi['createdAt']);
                      var difference = DateTime.now().difference(createdAt);
                      var trailingText = _buildTrailingText(difference, createdAt);
                      var textColor = Colors.black;
                      var cardColor = transaksi['statusBayar'] == 'Selesai' ? Colors.white : Colors.red[50];
                      return Card(
                        color: cardColor,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF2D67ED),
                            child: Icon(FontAwesomeIcons.moneyBillWave, color: Colors.white),
                          ),
                          title: Text(konsumen, style: TextStyle(color: textColor)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildDetailTransaksi(transaksi['detailTransaksi']),
                          ),
                          trailing: Text(trailingText, style: TextStyle(color: textColor)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailTransaksi(List<dynamic> detailTransaksi) {
    return detailTransaksi.map<Widget>((detail) {
      var layanan = detail['layanan']['nama'];
      var berat = detail['berat'].toString();
      var totalHarga = detail['total_harga'].toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('$layanan - ${berat}Kg', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Total Harga: Rp $totalHarga'),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  String _buildTrailingText(Duration difference, DateTime createdAt) {
    if (difference.inDays > 0) {
      return '${createdAt.day}-${createdAt.month}-${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
    } else {
      if (difference.inHours > 0) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit lalu';
      } else {
        return 'Beberapa saat lalu';
      }
    }
  }

  Widget headerWidget() {
    var userData = GetStorage().read('userData') ?? {};

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6DBDFF), Color(0xFF4563DB)], // Adjust based on your Figma design
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AppAsset.profile), // Adjust based on your asset path
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      userData['name'] ?? 'User',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    dashboardC.logout();
                  },
                  child: const Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total Transaksi',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            Row(
              children: [
                Obx(() => Text(
                  'Rp. ${dashboardC.isShow.value ? dashboardC.totalRupiah : "******"}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    dashboardC.showHide();
                  },
                  child: Obx(() => Icon(
                    dashboardC.isShow.value ? FontAwesomeIcons.eye : FontAwesomeIcons.solidEyeSlash,
                    color: Colors.white,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Implement action to view more details
              },
              child: const Row(
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    FontAwesomeIcons.arrowRight,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => InformationViews());
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.circleInfo,
                          color: Color(0xFF6DBDFF),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Informasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => ServiceView());
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.bookOpen,
                          color: Color(0xFF6DBDFF),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Layanan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => KonsumenView());
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.userAstronaut,
                          color: Color(0xFF6DBDFF),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Konsumen',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
