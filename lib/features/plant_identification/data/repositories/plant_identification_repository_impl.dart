import 'dart:io';
import 'package:plant_care_app/features/plant_identification/data/datasources/plant_net_service.dart';
import 'package:plant_care_app/features/plant_identification/domain/entities/plant_identification.dart';
import 'package:plant_care_app/features/plant_identification/domain/repositories/plant_identification_repository.dart';

class PlantIdentificationRepositoryImpl implements PlantIdentificationRepository {
  final PlantNetService service;

  PlantIdentificationRepositoryImpl(this.service);

  @override
  Future<PlantIdentification> identifyPlant(File imageFile) async {
    final model = await service.identifyPlant(imageFile);

    return PlantIdentification(
      bestMatch: model.bestMatch ?? 'Unknown',
      results: model.results
          .map((e) => PlantResult(
                score: e.score,
                scientificName: e.species.scientificName,
                commonNames: e.species.commonNames,
                familyName: e.species.family?.scientificName,
              ))
          .toList(),
    );
  }
}
