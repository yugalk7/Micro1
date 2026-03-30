import 'package:shared_preferences/shared_preferences.dart';

class UserService {
static Future<void> saveUser(String name, String address) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setString("name", name);
await prefs.setString("address", address);
}

static Future<Map<String, String>> getUser() async {
final prefs = await SharedPreferences.getInstance();


return {
  "name": prefs.getString("name") ?? "Health Worker",
  "address": prefs.getString("address") ?? "Not set",
};


}
}
