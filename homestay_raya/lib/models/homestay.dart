class Homestay {
  String? homestayId;
  String? homestayName;
  String? homestayDesc;
  String? homestayPrice;
  String? homestayQtyroom;
  String? homestayContact;
  String? homestayState;
  String? homestayLocal;
  String? homestayLat;
  String? homestayLng;
  String? homestayDate;

  Homestay(
      {this.homestayId,
      this.homestayName,
      this.homestayDesc,
      this.homestayPrice,
      this.homestayQtyroom,
      this.homestayContact,
      this.homestayState,
      this.homestayLocal,
      this.homestayLat,
      this.homestayLng,
      this.homestayDate});

  Homestay.fromJson(Map<String, dynamic> json) {
    homestayId = json['homestay_id'];
    homestayName = json['homestay_name'];
    homestayDesc = json['homestay_desc'];
    homestayPrice = json['homestay_price'];
    homestayQtyroom = json['homestay_qtyroom'];
    homestayContact = json['homestay_contact'];
    homestayState = json['homestay_state'];
    homestayLocal = json['homestay_local'];
    homestayLat = json['homestay_lat'];
    homestayLng = json['homestay_lng'];
    homestayDate = json['homestay_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['homestay_id'] = this.homestayId;
    data['homestay_name'] = this.homestayName;
    data['homestay_desc'] = this.homestayDesc;
    data['homestay_price'] = this.homestayPrice;
    data['homestay_qtyroom'] = this.homestayQtyroom;
    data['homestay_contact'] = this.homestayContact;
    data['homestay_state'] = this.homestayState;
    data['homestay_local'] = this.homestayLocal;
    data['homestay_lat'] = this.homestayLat;
    data['homestay_lng'] = this.homestayLng;
    data['homestay_date'] = this.homestayDate;
    return data;
  }
}