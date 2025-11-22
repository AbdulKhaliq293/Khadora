class PlantIdentificationModel {
  final String? bestMatch;
  final List<PlantResultModel> results;

  PlantIdentificationModel({
    this.bestMatch,
    required this.results,
  });

  factory PlantIdentificationModel.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationModel(
      bestMatch: json['bestMatch'] as String?,
      results: (json['results'] as List?)
              ?.map((e) => PlantResultModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PlantResultModel {
  final double score;
  final PlantSpeciesModel species;

  PlantResultModel({
    required this.score,
    required this.species,
  });

  factory PlantResultModel.fromJson(Map<String, dynamic> json) {
    return PlantResultModel(
      score: (json['score'] as num).toDouble(),
      species:
          PlantSpeciesModel.fromJson(json['species'] as Map<String, dynamic>),
    );
  }
}

class PlantSpeciesModel {
  final String scientificName;
  final List<String> commonNames;
  final PlantFamilyModel? family;

  PlantSpeciesModel({
    required this.scientificName,
    required this.commonNames,
    this.family,
  });

  factory PlantSpeciesModel.fromJson(Map<String, dynamic> json) {
    return PlantSpeciesModel(
      scientificName: json['scientificNameWithoutAuthor'] as String? ?? '',
      commonNames: (json['commonNames'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      family: json['family'] != null
          ? PlantFamilyModel.fromJson(json['family'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PlantFamilyModel {
  final String scientificName;

  PlantFamilyModel({required this.scientificName});

  factory PlantFamilyModel.fromJson(Map<String, dynamic> json) {
    return PlantFamilyModel(
      scientificName: json['scientificNameWithoutAuthor'] as String? ?? '',
    );
  }
}
