class RecommendationPlant {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final String history;
  final String origin;
  final String weather;
  final bool isPoisonous;
  final String description;
  final String fertilization;
  final String careLevel;
  final bool isIndoor;
  final String diseases;
  final String diseasePrevention;
  final String buyLink;

  RecommendationPlant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.history,
    required this.origin,
    required this.weather,
    required this.isPoisonous,
    required this.description,
    required this.fertilization,
    required this.careLevel,
    required this.isIndoor,
    required this.diseases,
    required this.diseasePrevention,
    required this.buyLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'imageUrl': imageUrl,
      'history': history,
      'origin': origin,
      'weather': weather,
      'isPoisonous': isPoisonous,
      'description': description,
      'fertilization': fertilization,
      'careLevel': careLevel,
      'isIndoor': isIndoor,
      'diseases': diseases,
      'diseasePrevention': diseasePrevention,
      'buyLink': buyLink,
    };
  }

  factory RecommendationPlant.fromMap(Map<String, dynamic> map, String id) {
    return RecommendationPlant(
      id: id,
      name: map['name'] ?? '',
      scientificName: map['scientificName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      history: map['history'] ?? '',
      origin: map['origin'] ?? '',
      weather: map['weather'] ?? '',
      isPoisonous: map['isPoisonous'] ?? false,
      description: map['description'] ?? '',
      fertilization: map['fertilization'] ?? '',
      careLevel: map['careLevel'] ?? '',
      isIndoor: map['isIndoor'] ?? true,
      diseases: map['diseases'] ?? '',
      diseasePrevention: map['diseasePrevention'] ?? '',
      buyLink: map['buyLink'] ?? '',
    );
  }
}
