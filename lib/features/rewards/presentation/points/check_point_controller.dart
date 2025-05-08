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
  
  // Nueva propiedad para controlar el orden de clasificación
  final Rx<bool> isDescendingOrder = true.obs;

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

  // Método para ordenar la lista por ventaId
  void sortByVentaId({bool? descending}) {
    // Si se proporciona un valor para descending, actualiza isDescendingOrder
    if (descending != null) {
      isDescendingOrder.value = descending;
    }
    
    // Crea una copia de la lista para ordenarla
    final sortedList = List<CheckPointsEntitie>.from(checkPoints);
    
    // Ordena por ventaId
    if (isDescendingOrder.value) {
      // Orden descendente (del más grande al más pequeño)
      sortedList.sort((a, b) => (b.ventaId ?? 0).compareTo(a.ventaId ?? 0));
    } else {
      // Orden ascendente (del más pequeño al más grande)
      sortedList.sort((a, b) => (a.ventaId ?? 0).compareTo(b.ventaId ?? 0));
    }
    
    // Asigna la lista ordenada
    checkPoints.assignAll(sortedList);
    
    print('🔢 Lista ordenada por ventaId - Orden descendente: ${isDescendingOrder.value}');
  }
  
  // Cambiar el orden de clasificación y re-ordenar la lista
  void toggleSortOrder() {
    isDescendingOrder.value = !isDescendingOrder.value;
    sortByVentaId();
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
        
        // Ordenar por ventaId (por defecto en orden descendente)
        sortByVentaId();
        
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
        
        // Ordenar por ventaId después de refrescar
        sortByVentaId();
        
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
      0, (sum, checkPoint) => sum + checkPoint.saldo_puntos);
    print('💰 Total de puntos: ${totalPoints.value}');
  }

  String formatPoints(double points) {
    return points.toStringAsFixed(0);
  }

  String get formattedTotalPoints {
    return formatPoints(totalPoints.value);
  }
}