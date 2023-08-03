class Address {
  String id;
  String name;
  String surname;
  String email;
  String telephone;
  String clear_address;
  String city_id;
  String town_id;
  String city;
  String town;

  String? billing_name;
  String? billing_surname;
  String? billing_email;
  String? billing_telephone;
  String? billing_city;
  String? billing_town;
  String? billing_clear_address;


  Address({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.telephone,
    required this.clear_address,
    required this.city_id,
    required this.town_id,
    required this.city,
    required this.town,

    this.billing_name,
    this.billing_surname,
    this.billing_email,
    this.billing_telephone,
    this.billing_city,
    this.billing_town,
    this.billing_clear_address,

  });
}
