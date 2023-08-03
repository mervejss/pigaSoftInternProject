class Category {
  final String id;
  var first_group_id;
  var second_group_id;
  var third_group_id;
  final String url;
  final String title;
  final String description;
  final String img_url;
  final String? banner_url;
  final String? home_banner_url;
  final bool? isNext;

  Category({
    required this.id,
    this.first_group_id,
    this.second_group_id,
    this.third_group_id,
    required this.url,
    required this.title,
    required this.description,
    required this.img_url,
      this.banner_url,
      this.home_banner_url,
     this.isNext,
  });


}
