import 'dart:io';
import 'package:plant_care_app/features/plant_identification/domain/entities/plant_identification.dart';
import 'package:plant_care_app/features/plant_identification/domain/repositories/plant_identification_repository.dart';

class IdentifyPlantUseCase {
  final PlantIdentificationRepository repository;

  IdentifyPlantUseCase(this.repository);

  Future<PlantIdentification> call(File imageFile) {
    return repository.identifyPlant(imageFile);
  }
}
