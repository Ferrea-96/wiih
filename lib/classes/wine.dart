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
// constants.dart

class WineOptions {
  static const List<String> types = [
    'Red',
    'White',
    'Rosé',
    'Sparkling',
    'Orange'
  ];
  static List<String> grapeVarieties = [
    'Aglianico',
    'Areni',
    'Barbera',
    'Blaufränkisch',
    'Brachetto',
    'Brunello',
    'Cabernet Franc',
    'Cabernet Sauvignon',
    'Carignan',
    'Carménère',
    'Charbono',
    'Cinsaut',
    'Cornalin',
    'Dolcetto',
    'Gamay',
    'Gamaret',
    'Graciano',
    'Grignolino',
    'Lambrusco',
    'Malbec',
    'Merlot',
    'Montepulciano',
    'Mourverdre',
    'Nebbiolo',
    'Negroamaro',
    "Nero d'Avola",
    'Petit Verdot',
    'Pignolo',
    'Pinot Noir',
    'Pinot Meunier',
    'Pinotage',
    'Sangiovese',
    'Syrah / Shiraz',
    'Susumaniello',
    'Trollinger',
    'Tempranillo',
    'Terret Noir',
    'Primitivo',
    'Zweigelt',
    'Arbois',
    'Arneis',
    'Chardonnay',
    'Chasselas',
    'Chenin Blanc',
    'Clairette',
    'Completer',
    'Gewürztraminer',
    'Grüner Veltliner',
    'Marsanne',
    'Müller-Thurgau',
    'Moscato',
    'Petite Arvine',
    'Petite Manseng',
    'Pinot Blanc',
    'Pinot Gris',
    'Prosecco',
    'Rauschling',
    'Riesling',
    'Roter Veltliner',
    'Roussanne',
    'Sauvignon Blanc',
    'Savagnin',
    'Sémilion',
    'Solaris',
    'Silvaner',
    'Trebbiano',
    'Verdejo',
    'Vermentino',
    'Viognier'
  ];
  static const List<String> countries = [
    'France',
    'Italy',
    'Spain',
    'Switzerland',
    'USA',
    'Germany',
    'Austria',
    'Australia',
    'Portugal',
    'Argentina',
    'Georgia',
    'Chile',
    'South Africa',
    'New Zealand'
  ];
}
