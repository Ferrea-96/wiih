class WineNote {
  int id;
  String name;
  int year;
  String description;
  int rating;

  WineNote({
    required this.id,
    required this.name,
    required this.year,
    required this.description,
    required this.rating,
  });

  // Convert object to a map for storing in shared preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // Changed from 'title' to 'name'
      'year': year,
      'description': description,
      'rating': rating,
    };
  }

  // Create an object from a map retrieved from shared preferences
  factory WineNote.fromJson(Map<String, dynamic> json) {
    return WineNote(
      id: json['id'],
      name: json['name'], // Corrected from 'title' to 'name'
      year: json['year'],
      description: json['description'],
      rating: json['rating'],
    );
  }
}
