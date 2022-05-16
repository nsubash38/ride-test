import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Preference {
  final _storage = FlutterSecureStorage();

  void storeUserCredentials(email, id) async {
    await _storage.write(key: "userid", value: id);
  }

  void storaUserRole(role) async{
    await _storage.write(key: "role", value: role);
  }

  Future<String?> getUserID ()async{
      return await _storage.read(key: "userid");
  }

  Future<String?> getRole() async{
    return await _storage.read(key: "role");
  }
}
