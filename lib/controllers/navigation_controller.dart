import 'package:get/get.dart';

class NavigationController extends GetxController {
  /// الفهرس الحالي للصفحة (التي يعرضها المستخدم الآن)
  var currentIndex = 0.obs;

  /// تغيير الصفحة عند الضغط على زر في الـ BottomNavigationBar
  void changePage(int index) {
    currentIndex.value = index;
  }
}
