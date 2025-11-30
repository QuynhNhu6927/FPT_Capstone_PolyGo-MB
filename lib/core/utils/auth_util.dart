import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../routes/app_routes.dart';

Future<void> forceLogout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');

  globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.login,
        (route) => false,
  );
}
