class PlantIdentification {
  final String bestMatch;
  final List<PlantResult> results;

  PlantIdentification({
    required this.bestMatch,
    required this.results,
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
