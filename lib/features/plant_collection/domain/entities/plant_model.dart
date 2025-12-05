class Plant {
  final String plantId;
  final String name;
  final String imageUrl;
  final String description;
  final String timeToWater;
  final bool isToxic;
  final bool isIndoor;
  final String category; // Added category field
  final String origin;
  final String history;
  final String? fertilizerInfo; // Added for fertilizer management
  
  // Schedule & Notification
  final int? waterFrequencyDays;
  final int? fertilizerFrequencyDays;
  final String? fertilizerType;
  final DateTime? nextWaterDate;
  final DateTime? nextFertilizeDate;

  final String? healthStatus; // Added for health status
  final List<String>? healthCheckHistory; // Added for history of health checks
  
  // Detailed Care Info
  final String? sunlight;
  final String? pruning;
  final String? hardiness;
  final String? careInstructions;
  final String? type;
  final String? cycle;
  final String? growthRate;
  final String? maintenance;
  final bool? poisonousToHumans;
  final bool? poisonousToPets;
  final bool? droughtTolerant;
  final bool? invasive;
  
  // API Reference
  final String? apiId;
  final String? apiSource;

  Plant({
    required this.plantId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.timeToWater,
    required this.isToxic,
    required this.isIndoor,
    this.category = 'Indoor', // Default to Indoor
    required this.origin,
    required this.history,
    this.fertilizerInfo,
    this.waterFrequencyDays,
    this.fertilizerFrequencyDays,
    this.fertilizerType,
    this.nextWaterDate,
    this.nextFertilizeDate,
    this.healthStatus,
    this.healthCheckHistory,
    this.sunlight,
    this.pruning,
    this.hardiness,
    this.careInstructions,
    this.type,
    this.cycle,
    this.growthRate,
    this.maintenance,
    this.poisonousToHumans,
    this.poisonousToPets,
    this.droughtTolerant,
    this.invasive,
    this.apiId,
    this.apiSource,
  });
}
