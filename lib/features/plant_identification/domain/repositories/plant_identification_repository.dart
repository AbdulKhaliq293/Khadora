import 'dart:io';
import 'package:plant_care_app/features/plant_identification/domain/entities/plant_identification.dart';

abstract class PlantIdentificationRepository {
  Future<PlantIdentification> identifyPlant(File imageFile);
}
