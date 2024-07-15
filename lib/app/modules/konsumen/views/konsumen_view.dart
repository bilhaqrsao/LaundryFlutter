import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/konsumen_controller.dart';
import '../../../model/konsumen_model.dart';

class KonsumenView extends GetView<KonsumenController> {
  final KonsumenController konsumenController = Get.put(KonsumenController());
  final RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Konsumen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => searchQuery.value = value,
              decoration: const InputDecoration(
                labelText: 'Cari konsumen...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                var filteredList = konsumenController.konsumenList.where((konsumen) =>
                    konsumen.nama.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    Konsumen konsumen = filteredList[index];
                    return _buildKonsumenTile(context, konsumen);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildKonsumenTile(BuildContext context, Konsumen konsumen) {
    return ListTile(
      title: Text(konsumen.nama),
      leading: const FaIcon(FontAwesomeIcons.user),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.edit),
            onPressed: () => _showEditDialog(context, konsumen),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.trash),
            onPressed: () => _confirmDelete(konsumen.id.toString()),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    Get.defaultDialog(
      title: 'Tambah Konsumen',
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Nama',
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: 'Tambah',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          konsumenController.createKonsumen(nameController.text);
          konsumenController.fetchKonsumen(); // Ambil data konsumen terbaru
          Get.back(); // Tutup dialog setelah berhasil tambah konsumen
        } else {
          Get.snackbar('Error', 'Nama konsumen tidak boleh kosong');
          // Dialog tidak ditutup di sini agar pengguna bisa memperbaiki input
        }
      },
    );
  }

  void _showEditDialog(BuildContext context, Konsumen konsumen) {
    final TextEditingController nameController = TextEditingController(text: konsumen.nama);

    Get.defaultDialog(
      title: 'Edit Konsumen',
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Nama',
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: 'Simpan',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          konsumenController.editKonsumen(konsumen.id.toString(), nameController.text);
          konsumenController.fetchKonsumen(); // Ambil data konsumen terbaru
          Get.back(); // Tutup dialog setelah berhasil edit konsumen
        } else {
          Get.snackbar('Error', 'Nama konsumen tidak boleh kosong');
        }
      },
    );
  }

  void _confirmDelete(String konsumenId) {
    Get.defaultDialog(
      title: 'Konfirmasi Hapus',
      middleText: 'Apakah Anda yakin ingin menghapus konsumen ini?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      onConfirm: () {
        konsumenController.deleteKonsumen(int.parse(konsumenId));
        konsumenController.fetchKonsumen(); // Ambil data konsumen terbaru
        Get.back();
      },
    );
  }
}
