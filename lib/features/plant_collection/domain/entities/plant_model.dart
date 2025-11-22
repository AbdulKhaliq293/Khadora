class Plant {
  final String plantId;
  final String name;
  final String imageUrl;
  final String description;
  final String timeToWater;
  final bool isToxic;
  final bool isIndoor;
  final String origin;
  final String history;
  final String? fertilizerInfo; // Added for fertilizer management
  final String? healthStatus; // Added for health status
  final List<String>? healthCheckHistory; // Added for history of health checks

  Plant({
    required this.plantId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.timeToWater,
    required this.isToxic,
    required this.isIndoor,
    required this.origin,
    required this.history,
    this.fertilizerInfo,
    this.healthStatus,
    this.healthCheckHistory,
  });
}
