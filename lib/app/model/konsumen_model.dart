// lib/app/model/konsumen_model.dart

class Konsumen {
  final int id;
  final String nama;
  final DateTime createdAt;
  final DateTime updatedAt;

  Konsumen({
    required this.id,
    required this.nama,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Konsumen.fromJson(Map<String, dynamic> json) {
    return Konsumen(
      id: json['id'],
      nama: json['nama'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
