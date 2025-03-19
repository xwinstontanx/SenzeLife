import '../provider/user_data_provider.dart';
import '../model/user.dart';


class UserService {
  static UserService? _instance;
  User? user;

  // Singleton method using factory design pattern
  UserService._();

  factory UserService() => _instance ??= UserService._();

  Future<void> setUser(String uid) async {
    user = User.fromMap(
        await UserDataProvider().getUser(uid) as Map<String, dynamic>);
  }

  User? getUser() {
    return user;
  }
}
