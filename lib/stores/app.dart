import 'package:get/get.dart';

class Controller extends GetxController {
  var count = 0.obs;
  var token = ''.obs;
  var userInfo = {}.obs;
  var bottomNavVisible = true.obs;
  var safeHeight = 0.0.obs;

  setToken(val) => token.value = val;
  setUserInfo(val) => userInfo.value = val;
  setBottomNavVisible(val) => bottomNavVisible.value = val;
  setSafeHeight(val) => safeHeight.value = val;
  increment() => count++;
}
