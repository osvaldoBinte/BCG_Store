import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_loading.dart';
import 'package:BCG_Store/features/rewards/presentation/points/widget/point_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpansionController extends GetxController {
  late List<RxBool> expandedItems;
  
  ExpansionController({
    required int itemCount,
    int? initialExpandedIndex,
  }) {
    expandedItems = List.generate(
      itemCount,
      (index) => (index == initialExpandedIndex).obs
    );
  }
  
  void toggleExpansion(int index) {
    expandedItems[index].value = !expandedItems[index].value;
  }
  
  bool isExpanded(int index) {
    return expandedItems[index].value;
  }
}
