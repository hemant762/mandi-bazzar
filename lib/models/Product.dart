class Product {
  String hindiName, engName,heName, description,img;
  int price, quantity, id,isAvailable;


  Product({this.hindiName, this.engName, this.heName, this.description, this.img,
      this.price, this.quantity, this.id,
      this.isAvailable});

  // It create an Category from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json["id"]),
      price: int.parse(json["price"]),
      quantity: int.parse(json["quantity"]),
      isAvailable: int.parse(json["is_available"]),
      hindiName: json["hindi_name"],
      engName: json["english_name"],
      heName: json["hinglish_name"],
      description: json["description"],
      img: json["img"],
    );
  }
}