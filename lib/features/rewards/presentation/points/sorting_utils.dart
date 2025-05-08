// Archivo: lib/common/utils/sorting_utils.dart

/// Clase de utilidad para métodos de ordenamiento avanzados
class SortingUtils {
  /// Compara dos strings que podrían ser numéricos
  ///
  /// Si ambos strings pueden convertirse a números, los compara numéricamente.
  /// De lo contrario, realiza una comparación de strings estándar.
  /// 
  /// [a] y [b] son los strings a comparar
  /// [isDescending] determina si el orden es descendente (por defecto es false)
  /// 
  /// Returns:
  /// * Un valor negativo si a < b
  /// * Cero si a == b
  /// * Un valor positivo si a > b
  static int compareNumericStrings(String? a, String? b, {bool isDescending = false}) {
    final String safeA = a ?? '';
    final String safeB = b ?? '';
    
    if (safeA.isEmpty && safeB.isEmpty) return 0;
    if (safeA.isEmpty) return isDescending ? 1 : -1;
    if (safeB.isEmpty) return isDescending ? -1 : 1;

    // Intentar conversión a números
    try {
      final int numA = int.parse(safeA);
      final int numB = int.parse(safeB);
      
      if (isDescending) {
        return numB.compareTo(numA);
      } else {
        return numA.compareTo(numB);
      }
    } catch (e) {
      // Si falla la conversión, comparar como strings
      if (isDescending) {
        return safeB.compareTo(safeA);
      } else {
        return safeA.compareTo(safeB);
      }
    }
  }
  
  /// Compara dos strings como fechas
  ///
  /// Intenta convertir los strings en objetos DateTime y los compara.
  /// Si la conversión falla, usa comparación de strings estándar.
  /// 
  /// [a] y [b] son los strings con formato de fecha a comparar
  /// [isDescending] determina si el orden es descendente (por defecto es false)
  static int compareDates(String? a, String? b, {bool isDescending = false}) {
    final String safeA = a ?? '';
    final String safeB = b ?? '';
    
    if (safeA.isEmpty && safeB.isEmpty) return 0;
    if (safeA.isEmpty) return isDescending ? 1 : -1;
    if (safeB.isEmpty) return isDescending ? -1 : 1;

    try {
      final DateTime dateA = DateTime.parse(safeA);
      final DateTime dateB = DateTime.parse(safeB);
      
      if (isDescending) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    } catch (e) {
      // Si falla la conversión, comparar como strings
      if (isDescending) {
        return safeB.compareTo(safeA);
      } else {
        return safeA.compareTo(safeB);
      }
    }
  }
  
  /// Compara dos valores numéricos (double o int)
  ///
  /// [a] y [b] son los valores numéricos a comparar
  /// [isDescending] determina si el orden es descendente (por defecto es false)
  static int compareNumbers(num? a, num? b, {bool isDescending = false}) {
    final double safeA = a?.toDouble() ?? 0.0;
    final double safeB = b?.toDouble() ?? 0.0;
    
    if (isDescending) {
      return safeB.compareTo(safeA);
    } else {
      return safeA.compareTo(safeB);
    }
  }
}