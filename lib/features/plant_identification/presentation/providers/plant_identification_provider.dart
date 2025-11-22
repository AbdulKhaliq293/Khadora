import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/plant_net_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/perenual_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/trefle_service.dart';
import 'package:plant_care_app/features/plant_identification/data/datasources/plant_id_service.dart';
import 'package:plant_care_app/features/plant_identification/data/repositories/plant_identification_repository_impl.dart';
import 'package:plant_care_app/features/plant_identification/domain/entities/plant_identification.dart';
import 'package:plant_care_app/features/plant_identification/domain/repositories/plant_identification_repository.dart';
import 'package:plant_care_app/features/plant_identification/domain/usecases/identify_plant_usecase.dart';

// Service
final plantNetServiceProvider = Provider<PlantNetService>((ref) {
  return PlantNetService();
});

final perenualServiceProvider = Provider<PerenualService>((ref) {
  return PerenualService();
});

final trefleServiceProvider = Provider<TrefleService>((ref) {
  return TrefleService();
});

final plantIdServiceProvider = Provider<PlantIdService>((ref) {
  return PlantIdService();
});

// Repository
final plantIdentificationRepositoryProvider =
    Provider<PlantIdentificationRepository>((ref) {
  final plantNetService = ref.watch(plantNetServiceProvider);
  final perenualService = ref.watch(perenualServiceProvider);
  final trefleService = ref.watch(trefleServiceProvider);
  final plantIdService = ref.watch(plantIdServiceProvider);
  return PlantIdentificationRepositoryImpl(
    plantNetService, 
    perenualService, 
    trefleService,
    plantIdService
  );
});

// Use Case
final identifyPlantUseCaseProvider = Provider<IdentifyPlantUseCase>((ref) {
  final repository = ref.watch(plantIdentificationRepositoryProvider);
  return IdentifyPlantUseCase(repository);
});

// Notifier
class PlantIdentificationNotifier extends StateNotifier<AsyncValue<PlantIdentification?>> {
  final IdentifyPlantUseCase _identifyPlantUseCase;

  PlantIdentificationNotifier(this._identifyPlantUseCase)
      : super(const AsyncValue.data(null));

  Future<void> identifyPlant(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final result = await _identifyPlantUseCase(imageFile);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final plantIdentificationNotifierProvider =
    StateNotifierProvider<PlantIdentificationNotifier, AsyncValue<PlantIdentification?>>((ref) {
  final useCase = ref.watch(identifyPlantUseCaseProvider);
  return PlantIdentificationNotifier(useCase);
});
