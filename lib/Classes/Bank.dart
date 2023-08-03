class Bank {
  final String id;
  final String title;
  final String description;
  final String imgUrl;
  final int rank;
  final bool isActive;
  final String createdAt;

  Bank({
    required this.id,
    required this.title,
    required this.description,
    required this.imgUrl,
    required this.rank,
    required this.isActive,
    required this.createdAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imgUrl: json['img_url'],
      rank: int.parse(json['rank']),
      isActive: json['isActive'] == '1',
      createdAt: json['createdAt'],
    );
  }
}
