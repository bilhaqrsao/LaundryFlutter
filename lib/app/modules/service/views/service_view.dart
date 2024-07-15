import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:new_laundry/app/modules/service/controllers/service_controller.dart';
import 'package:new_laundry/app/model/service_model.dart';

class ServiceView extends GetView<ServiceController> {
  final ServiceController serviceC = Get.put(ServiceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: controller.searchLayanan,
              decoration: InputDecoration(
                hintText: 'Cari Layanan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchLayanan();
        },
        child: Obx(() {
          if (controller.layananList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: controller.searchResult.length,
              itemBuilder: (context, index) {
                var layanan = controller.searchResult[index];
                return _buildLayananCard(context, layanan);
              },
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLayananCard(BuildContext context, ServiceModel layanan) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${layanan.nama ?? ''}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Rp.${layanan.harga?.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},') ?? ''}',
                  ),
                  Text('${layanan.durasi ?? ''} Hari'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.trash),
              onPressed: () => _confirmDeleteLayanan(context, layanan.id!),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.edit),
              onPressed: () => _dialogEdit(context, layanan),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteLayanan(BuildContext context, int layananId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus layanan ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                serviceC.deleteLayanan(layananId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _dialogAdd(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    Get.defaultDialog(
      title: 'Tambah Layanan',
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durasi',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            var nama = nameController.text;
            var harga = double.tryParse(priceController.text) ?? 0;
            var durasi = int.tryParse(durationController.text) ?? 0;

            if (nama.isNotEmpty && harga > 0 && durasi > 0) {
              serviceC.addLayanan(nama, harga, durasi);
              Navigator.of(context).pop();
            } else {
              Get.snackbar('Error', 'Harap lengkapi semua kolom dengan benar');
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _dialogEdit(BuildContext context, ServiceModel layanan) {
    final TextEditingController nameController = TextEditingController(text: layanan.nama);
    final TextEditingController priceController = TextEditingController(text: layanan.harga?.toString() ?? '');
    final TextEditingController durationController = TextEditingController(text: layanan.durasi?.toString() ?? '');

    Get.defaultDialog(
      title: 'Edit Layanan',
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durasi',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            var nama = nameController.text;
            var harga = int.tryParse(priceController.text) ?? 0;
            var durasi = int.tryParse(durationController.text) ?? 0;

            if (nama.isNotEmpty && harga > 0 && durasi > 0) {
              serviceC.editLayanan(layanan.id!, nama, harga, durasi); // Edit layanan dengan parameter yang diperlukan
              Navigator.of(context).pop(); // Tutup dialog setelah berhasil disimpan
            } else {
              Get.snackbar('Error', 'Harap lengkapi semua kolom dengan benar');
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

}
