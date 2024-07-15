import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:new_laundry/app/model/service_model.dart';
import '../controllers/trasanction_controller.dart';

class TrasanctionView extends GetView<TrasanctionController> {
  TrasanctionView({Key? key}) : super(key: key);
  final tController = Get.put(TrasanctionController());

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANSAKSI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKonsumenDropdown(),
                const SizedBox(height: 20),
                Expanded(child: _buildDetailTransaksiList()),
                const Divider(),
                _buildTotalHarga(),
                const SizedBox(height: 10),
                _buildPayButton(),
                const SizedBox(height: 30),
              ],
            ),
            Positioned(
              bottom: 150,
              right: 16,
              child: FloatingActionButton(
                onPressed: _showLayananDialog,
                child: const Icon(Icons.add, size: 30),
                tooltip: 'Tambah Item',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonsumenDropdown() {
    return Obx(() {
      return DropdownSearch<String>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Cari Konsumen',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        items: tController.konsumenList.map((konsumen) => konsumen.nama).toList(),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Cari Konsumen",
            hintText: "Pilih Konsumen",
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            border: OutlineInputBorder(),
          ),
        ),
        onChanged: (value) {
          if (value != null) {
            tController.selectedKonsumenName.value = value;
          }
        },
        selectedItem: tController.selectedKonsumenName.value.isEmpty
            ? null
            : tController.selectedKonsumenName.value,
      );
    });
  }

  Widget _buildDetailTransaksiList() {
    return Obx(() {
      return ListView.builder(
        itemCount: tController.detailTransaksiList.length,
        itemBuilder: (context, index) {
          final detailTransaksi = tController.detailTransaksiList[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
            ),
            title: Text(detailTransaksi['nama']),
            subtitle: Text(currencyFormatter.format(detailTransaksi['harga'])),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${detailTransaksi['jumlah']} Kg',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    tController.removeLayanan(index);
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildTotalHarga() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Harga',
          style: TextStyle(fontSize: 18),
        ),
        Obx(() {
          int totalHarga = tController.detailTransaksiList.fold<int>(
              0, (sum, item) => sum + (item['harga'] as int));
          return Text(
            currencyFormatter.format(totalHarga),
            style: const TextStyle(fontSize: 18),
          );
        }),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (tController.detailTransaksiList.isEmpty) {
            Get.snackbar('Error', 'Tidak ada layanan yang ditambahkan');
            return;
          }
          if (tController.selectedKonsumenName.isEmpty) {
            Get.snackbar('Error', 'Silakan pilih konsumen terlebih dahulu');
            return;
          }
          Get.dialog(
            AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Apakah Anda yakin ingin melakukan pembayaran?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back(); // Tutup dialog konfirmasi
                    _showLoadingDialog();
                    tController.saveTransaction(); // Simpan transaksi
                    Get.back(); // Tutup dialog loading
                    _showInvoiceDialog(); // Tampilkan invoice setelah transaksi berhasil
                  },
                  child: const Text('Ya'),
                ),
              ],
            ),
          );
        },
        child: const Text('Simpan'),
      ),
    );
  }

  void _showLoadingDialog() {
    Get.dialog(
      Center(
        child: SpinKitThreeInOut(
          color: Colors.blue,
          size: 50.0,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showInvoiceDialog() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Nama Konsumen: ${tController.selectedKonsumenName.value}'),
              const SizedBox(height: 10),
              const Text('Layanan:'),
              ...tController.detailTransaksiList.map((item) {
                return Text('${item['nama']} - ${item['jumlah']} Kg - ${currencyFormatter.format(item['harga'])}');
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Tutup dialog invoice
                },
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLayananDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    tController.searchLayanan(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari Layanan',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: tController.searchResultLayanan.length,
                    itemBuilder: (context, index) {
                      final layanan = tController.searchResultLayanan[index];
                      return ListTile(
                        title: Text(layanan.nama!),
                        subtitle: Text(currencyFormatter.format(layanan.harga)),
                        onTap: () {
                          _showJumlahDialog(layanan);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJumlahDialog(ServiceModel layanan) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jumlah untuk ${layanan.nama}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan jumlah',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  tController.itemCount.value = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (tController.itemCount.value <= 0) {
                    Get.snackbar('Error', 'Jumlah layanan harus lebih dari 0');
                    return;
                  }
                  tController.addLayanan(layanan, tController.itemCount.value);
                  Get.back(closeOverlays: true); // Tutup semua dialog
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
