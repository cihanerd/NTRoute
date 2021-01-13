class Barkod {
  int barcode;
  double latitude;
  double longitude;
  String customerName;
  String customerPhone;
  String customerAddress;

  Barkod(
      {this.barcode,
      this.latitude,
      this.longitude,
      this.customerName,
      this.customerPhone,
      this.customerAddress});

  Barkod.fromJson(Map<String, dynamic> json) {
    barcode = json['Barcode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    customerName = json['CustomerName'];
    customerPhone = json['CustomerPhone'];
    customerAddress = json['CustomerAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Barcode'] = this.barcode;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['CustomerName'] = this.customerName;
    data['CustomerPhone'] = this.customerPhone;
    data['CustomerAddress'] = this.customerAddress;
    return data;
  }
}
