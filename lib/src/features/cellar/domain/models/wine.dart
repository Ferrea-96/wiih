class Wine {
  int id;
  String name;
  String type;
  String winery;
  String country;
  String grapeVariety;
  int year;
  int price;
  String? imageUrl;
  int _bottleCount;

  Wine({
    required this.id,
    required this.name,
    required this.type,
    required this.winery,
    required this.country,
    required this.grapeVariety,
    required this.year,
    required this.price,
    required this.imageUrl,
    required int bottleCount,
  }) : _bottleCount = bottleCount >= 0 ? bottleCount : 0;

  int get bottleCount => _bottleCount;

  set bottleCount(int value) {
    _bottleCount = value >= 0 ? value : 0;
  }

  // Convert Wine object to a map for storing in shared preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'winery': winery,
      'country': country,
      'grapeVariety': grapeVariety,
      'year': year,
      'price': price,
      'imageUrl': imageUrl,
      'bottleCount': bottleCount,
    };
  }

  // Create a Wine object from a map retrieved from shared preferences
  factory Wine.fromJson(Map<String, dynamic> json) {
    return Wine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      winery: json['winery'],
      country: json['country'],
      grapeVariety: json['grapeVariety'],
      year: json['year'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      bottleCount: json['bottleCount'] ?? 0,
    );
  }
}
