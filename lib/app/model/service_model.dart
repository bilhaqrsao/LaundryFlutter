class ServiceModel {
  int? id;
  String? nama;
  int? harga;
  int? durasi;
  String? createdAt;
  String? updatedAt;

  ServiceModel({
    this.id,
    this.nama,
    this.harga,
    this.durasi,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      durasi: json['durasi'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
