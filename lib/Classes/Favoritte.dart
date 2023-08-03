class Favoritte {
  String value;
  String id;
  String url;
  String codeUrl;
  String isHome;
  String isActive;
  String price;
  String discountPrice;
  String title;
  String desi;
  String isDiscount;
  String imgUrl;
  String isCover;
  String productId;
  String memberId;
  String brandTitle;
  int point;
  int review;
  double discountRatio;

  Favoritte({
    required this.value,
    required this.id,
    required this.url,
    required this.codeUrl,
    required this.isHome,
    required this.isActive,
    required this.price,
    required this.discountPrice,
    required this.title,
    required this.desi,
    required this.isDiscount,
    required this.imgUrl,
    required this.isCover,
    required this.productId,
    required this.memberId,
    required this.brandTitle,
    required this.point,
    required this.review,
    required this.discountRatio,
  });

  factory Favoritte.fromJson(Map<String, dynamic> json) {
    return Favoritte(
      value: json['value'],
      id: json['id'],
      url: json['url'],
      codeUrl: json['code_url'],
      isHome: json['isHome'],
      isActive: json['isActive'],
      price: json['price'],
      discountPrice: json['discount_price'],
      title: json['title'],
      desi: json['desi'],
      isDiscount: json['isDiscount'],
      imgUrl: json['img_url'],
      isCover: json['isCover'],
      productId: json['product_id'],
      memberId: json['member_id'],
      brandTitle: json['brand_title'],
      point: int.parse(json['point'].toString()),
      review: int.parse(json['review'].toString()),
      discountRatio: double.parse(json['discountRatio'].toString()),
    );
  }
}
