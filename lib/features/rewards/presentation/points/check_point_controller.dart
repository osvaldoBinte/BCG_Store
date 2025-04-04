import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/check_point_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CheckPointController extends GetxController {
  final CheckPointUsecase checkPointUsecase;

  CheckPointController({required this.checkPointUsecase});

  final RxList<CheckPointsEntitie> checkPoints = <CheckPointsEntitie>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble totalPoints = 0.0.obs;
  
  // Variable para controlar si ya se intentó cargar los datos
  final RxBool _hasAttemptedLoad = false.obs;
  
  // Variable para saber si no hay puntos (distinción entre error y vacío)
  final RxBool hasNoPoints = false.obs;

  @override
  void onInit() {
    super.onInit();
    // No usamos Future.delayed aquí, eso puede causar problemas
    // La carga se manejará desde la vista
  }
  
  // Este método se llamará cuando la pantalla se vuelva visible
  @override
  void onReady() {
    super.onReady();
    // Solo cargar si no se ha intentado cargar antes
    if (!_hasAttemptedLoad.value) {
      fetchCheckPoints();
    }
  }

  Future<void> fetchCheckPoints() async {
    try {
      // Marcar que ya se intentó cargar
      _hasAttemptedLoad.value = true;
      
      // Inicializamos el estado
      isLoading.value = true;
      errorMessage.value = '';
      hasNoPoints.value = false;
      
      print('🔄 Cargando datos de puntos...');
      
      // Obtener los datos
      final result = await checkPointUsecase.execute();
      
      // Comprobar si el resultado está vacío
      if (result.isEmpty) {
        print('ℹ️ No se encontraron puntos disponibles');
        // En este caso, no es un error, simplemente no hay puntos
        hasNoPoints.value = true;
        checkPoints.clear();
        totalPoints.value = 0;
      } else {
        // Actualizar los datos en la UI
        print('✅ Puntos cargados: ${result.length}');
        checkPoints.assignAll(result);
        
        // Calcular puntos totales
        _calculateTotalPoints();
        hasNoPoints.value = false;
      }
      
    } catch (e) {
      print('❌ Error al cargar puntos: $e');
      
      // Lista de términos que indican "no hay puntos" en lugar de un error real
      final List<String> noPointsErrorTerms = [
        '404', 
        'Not Found', 
        'Recurso no encontrado',
        'recurso no encontrado',
        'No encontrado'
      ];
      
      // Verificar si el error contiene alguno de los términos que indican "no hay puntos"
      bool isNoPointsError = noPointsErrorTerms.any((term) => e.toString().contains(term));
      
      if (isNoPointsError) {
        print('ℹ️ Error de tipo "no hay puntos": $e');
        // Tratar como "no hay puntos" en lugar de error
        hasNoPoints.value = true;
        errorMessage.value = '';
        checkPoints.clear();
        totalPoints.value = 0;
      } else {
        // Otros errores se muestran como mensajes de error
        errorMessage.value = 'Error al cargar los puntos: ${e.toString()}';
        hasNoPoints.value = false;
      }
    } finally {
      // Finalizar carga en cualquier caso
      isLoading.value = false;
    }
  }

  // Método para recargar los datos manualmente (p.ej. para pull-to-refresh)
  Future<void> refreshCheckPoints() async {
    // Reiniciar estado de error pero mantener datos antiguos visibles
    errorMessage.value = '';
    
    try {
      print('🔄 Actualizando datos de puntos...');
      // No mostrar spinner de carga completa para refresh
      final result = await checkPointUsecase.execute();
      
      if (result.isEmpty) {
        print('ℹ️ No se encontraron puntos disponibles (refresh)');
        hasNoPoints.value = true;
        checkPoints.clear();
        totalPoints.value = 0;
      } else {
        print('✅ Puntos actualizados: ${result.length}');
        checkPoints.assignAll(result);
        _calculateTotalPoints();
        hasNoPoints.value = false;
      }
    } catch (e) {
      print('❌ Error al actualizar puntos: $e');
      
      // Lista de términos que indican "no hay puntos" en lugar de un error real
      final List<String> noPointsErrorTerms = [
        '404', 
        'Not Found', 
        'Recurso no encontrado',
        'recurso no encontrado',
        'No encontrado'
      ];
      
      // Verificar si el error contiene alguno de los términos que indican "no hay puntos"
      bool isNoPointsError = noPointsErrorTerms.any((term) => e.toString().contains(term));
      
      if (isNoPointsError) {
        print('ℹ️ Error de tipo "no hay puntos" (refresh): $e');
        hasNoPoints.value = true;
        errorMessage.value = '';
        checkPoints.clear();
        totalPoints.value = 0;
      } else {
        errorMessage.value = 'Error al actualizar: ${e.toString()}';
      }
    }
  }

  void _calculateTotalPoints() {
    totalPoints.value = checkPoints.fold(
      0, (sum, checkPoint) => sum + checkPoint.monedero);
    print('💰 Total de puntos: ${totalPoints.value}');
  }

  // Helper method to format points as string
  String formatPoints(double points) {
    return points.toStringAsFixed(0);
  }

  // Helper method to get formatted total points
  String get formattedTotalPoints {
    return formatPoints(totalPoints.value);
  }
}