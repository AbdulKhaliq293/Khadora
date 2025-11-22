class PlantIdentification {
  final String bestMatch;
  final List<PlantResult> results;
  
  // Perenual Detailed Care Details
  final String? description;
  final String? watering;
  final String? sunlight;
  final String? pruningMonth;
  final String? hardiness;
  final String? careInstructions; // Detailed guide
  
  // Additional Details
  final String? type;
  final String? cycle;
  final String? growthRate;
  final String? maintenance;
  final bool? indoor;
  final bool? poisonousToHumans;
  final bool? poisonousToPets;
  final bool? droughtTolerant;
  final bool? invasive;
  final List<String>? origin;
  
  // API Reference
  final String? apiId;
  final String? apiSource; // 'perenual' or 'trefle'

  PlantIdentification({
    required this.bestMatch,
    required this.results,
    this.description,
    this.watering,
    this.sunlight,
    this.pruningMonth,
    this.hardiness,
    this.careInstructions,
    this.type,
    this.cycle,
    this.growthRate,
    this.maintenance,
    this.indoor,
    this.poisonousToHumans,
    this.poisonousToPets,
    this.droughtTolerant,
    this.invasive,
    this.origin,
    this.apiId,
    this.apiSource,
  });
}

class PlantResult {
  final double score;
  final String scientificName;
  final List<String> commonNames;
  final String? familyName;

  PlantResult({
    required this.score,
    required this.scientificName,
    required this.commonNames,
    this.familyName,
  });
}
