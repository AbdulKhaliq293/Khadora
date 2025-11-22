import 'dart:io';
import 'package:plant_care_app/features/plant_identification/data/datasources/plant_net_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/perenual_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/trefle_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/plant_id_service.dart';
import 'package:plant_care_app/features/plant_identification/domain/entities/plant_identification.dart';
import 'package:plant_care_app/features/plant_identification/domain/repositories/plant_identification_repository.dart';

class PlantIdentificationRepositoryImpl implements PlantIdentificationRepository {
  final PlantNetService plantNetService;
  final PerenualService perenualService;
  final TrefleService trefleService;
  final PlantIdService plantIdService;

  PlantIdentificationRepositoryImpl(
    this.plantNetService, 
    this.perenualService,
    this.trefleService,
    this.plantIdService,
  );

  @override
  Future<PlantIdentification> identifyPlant(File imageFile) async {
    // 1. Identify with PlantNet
    final model = await plantNetService.identifyPlant(imageFile);
    
    String? description;
    String? watering;
    String? sunlight;
    String? pruningMonth;
    String? hardiness;
    String? careInstructions;
    
    String? type;
    String? cycle;
    String? growthRate;
    String? maintenance;
    bool? indoor;
    bool? poisonousToHumans;
    bool? poisonousToPets;
    bool? droughtTolerant;
    bool? invasive;
    List<String>? origin;
    String? apiId;
    String? apiSource;

    // 2. Fetch details from Perenual or Plant.id if a match is found
    if (model.bestMatch != null) {
      // Clean the search query (remove author citations)
      // e.g. "Dieffenbachia seguine (Jacq.) Schott" -> "Dieffenbachia seguine"
      String searchQuery = model.bestMatch!;
      if (searchQuery.contains(' ')) {
        final parts = searchQuery.split(' ');
        if (parts.length > 2) {
          searchQuery = '${parts[0]} ${parts[1]}';
        }
      }

      // Try Perenual First
      try {
        final perenualId = await perenualService.searchPlantId(searchQuery);
        
        if (perenualId != null) {
          final details = await perenualService.getPlantDetails(perenualId);
          
          if (details != null) {
            // Only consider Perenual successful if we actually got details
            apiId = perenualId.toString();
            apiSource = 'perenual';
            
            description = details['description'];
            watering = details['watering'];
            type = details['type'];
            cycle = details['cycle'];
            growthRate = details['growth_rate'];
            maintenance = details['maintenance'];
            indoor = details['indoor'] == true;
            poisonousToHumans = details['poisonous_to_humans'] == 1 || details['poisonous_to_humans'] == true;
            poisonousToPets = details['poisonous_to_pets'] == 1 || details['poisonous_to_pets'] == true;
            droughtTolerant = details['drought_tolerant'] == true;
            invasive = details['invasive'] == true;
            
            if (details['origin'] is List) {
              origin = (details['origin'] as List).map((e) => e.toString()).toList();
            }
            
            if (details['sunlight'] is List) {
               sunlight = (details['sunlight'] as List).join(', ');
            }
            
            if (details['pruning_month'] is List) {
               pruningMonth = (details['pruning_month'] as List).join(', ');
            }
            
            if (details['hardiness'] is Map) {
              hardiness = '${details['hardiness']['min']} - ${details['hardiness']['max']}';
            }

            if (details['care_guides'] != null) {
              careInstructions = await perenualService.getCareGuideDescription(details['care_guides']);
            }
          }
        }
      } catch (e) {
        print('Error fetching Perenual details: $e');
      }

      // Try Plant.id as Fallback (if Perenual failed or returned no ID)
      if (apiId == null) {
        try {
          final plantIdAccessToken = await plantIdService.searchPlantId(searchQuery);
          
          if (plantIdAccessToken != null) {
            apiId = plantIdAccessToken;
            apiSource = 'plant_id';
            final details = await plantIdService.getPlantDetails(plantIdAccessToken);
            
            if (details != null) {
              // Description
              if (details['description'] != null && details['description']['value'] != null) {
                description = details['description']['value'];
              }
              
              // Watering
              if (details['best_watering'] != null) {
                watering = details['best_watering'];
              } else if (details['watering'] != null) {
                final min = details['watering']['min'];
                final max = details['watering']['max'];
                if (min != null && max != null) {
                  watering = 'Watering frequency: $min to $max';
                }
              }
              
              // Sunlight
              if (details['best_light_condition'] != null) {
                sunlight = details['best_light_condition'];
              }
              
              // Soil / Maintenance
              if (details['best_soil_type'] != null) {
                maintenance = 'Soil: ${details['best_soil_type']}';
              }
              
              // Toxicity
              if (details['toxicity'] != null) {
                final toxicStr = details['toxicity'].toString().toLowerCase();
                poisonousToHumans = toxicStr.contains('human') || toxicStr.contains('toxic to humans');
                poisonousToPets = toxicStr.contains('animal') || toxicStr.contains('pet') || toxicStr.contains('toxic to animals');
                // Store full string in careInstructions
                careInstructions = (careInstructions ?? '') + '\n\nToxicity: ${details['toxicity']}';
              }
              
              // Propagation
              if (details['propagation_methods'] != null && details['propagation_methods'] is List) {
                final methods = (details['propagation_methods'] as List).join(', ');
                cycle = 'Propagation: $methods';
              }
              
              // Cultural Significance
              if (details['cultural_significance'] != null) {
                 careInstructions = (careInstructions ?? '') + '\n\nCultural Significance: ${details['cultural_significance']}';
              }
            }
          }
        } catch (e) {
          print('Error fetching Plant.id details: $e');
        }
      }
    }

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
      description: description,
      watering: watering,
      sunlight: sunlight,
      pruningMonth: pruningMonth,
      hardiness: hardiness,
      careInstructions: careInstructions,
      type: type,
      cycle: cycle,
      growthRate: growthRate,
      maintenance: maintenance,
      indoor: indoor,
      poisonousToHumans: poisonousToHumans,
      poisonousToPets: poisonousToPets,
      droughtTolerant: droughtTolerant,
      invasive: invasive,
      origin: origin,
      apiId: apiId,
      apiSource: apiSource,
    );
  }
}
