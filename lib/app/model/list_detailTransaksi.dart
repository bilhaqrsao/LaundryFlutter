class ListDetailTransaksi {
  int? id;
  int? userId;
  int? konsumenId;
  int? total;
  String? statusAmbil;
  String? statusBayar;
  String? tglAmbil;
  String? createdAt;
  String? updatedAt;
  Konsumen? konsumen;
  List<DetailTransaksi>? detailTransaksi;

  ListDetailTransaksi({
    this.id,
    this.userId,
    this.konsumenId,
    this.total,
    this.statusAmbil,
    this.statusBayar,
    this.tglAmbil,
    this.createdAt,
    this.updatedAt,
    this.konsumen,
    this.detailTransaksi,
  });

  factory ListDetailTransaksi.fromJson(Map<String, dynamic> json) {
    return ListDetailTransaksi(
      id: json['id'],
      userId: json['userId'],
      konsumenId: json['konsumenId'],
      total: json['total'],
      statusAmbil: json['statusAmbil'],
      statusBayar: json['statusBayar'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      konsumen: json['konsumen'] != null ? Konsumen.fromJson(json['konsumen']) : null,
      detailTransaksi: json['detailTransaksi'] != null
          ? List<DetailTransaksi>.from(json['detailTransaksi'].map((x) => DetailTransaksi.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'userId': userId,
      'konsumenId': konsumenId,
      'total': total,
      'statusAmbil': statusAmbil,
      'statusBayar': statusBayar,
      'tglAmbil': tglAmbil,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'konsumen': konsumen?.toJson(),
      'detailTransaksi': detailTransaksi != null ? detailTransaksi!.map((x) => x.toJson()).toList() : null,
    };
    return data;
  }
}

class Konsumen {
  String? nama;

  Konsumen({this.nama});

  factory Konsumen.fromJson(Map<String, dynamic> json) {
    return Konsumen(
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nama': nama,
    };
    return data;
  }
}

class DetailTransaksi {
  int? id;
  int? transaksiId;
  int? layananId;
  int? berat;
  int? harga;
  int? totalHarga;
  Konsumen? layanan;

  DetailTransaksi({
    this.id,
    this.transaksiId,
    this.layananId,
    this.berat,
    this.harga,
    this.totalHarga,
    this.layanan,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      id: json['id'],
      transaksiId: json['transaksiId'],
      layananId: json['layananId'],
      berat: json['berat'],
      harga: json['harga'],
      totalHarga: json['total_harga'],
      layanan: json['layanan'] != null ? Konsumen.fromJson(json['layanan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'transaksiId': transaksiId,
      'layananId': layananId,
      'berat': berat,
      'harga': harga,
      'total_harga': totalHarga,
      'layanan': layanan?.toJson(),
    };
    return data;
  }

  static List<DetailTransaksi> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data.map((item) => DetailTransaksi.fromJson(item)).toList();
  }
}
