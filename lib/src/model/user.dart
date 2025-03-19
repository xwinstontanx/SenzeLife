class User {
  final String uid;
  final String email;
  final String name;
  final String organizationID;
  final String phoneNumber;
  final String fcm;
  final bool alertNotification;
  final bool ruleBasedNotification;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.organizationID,
    required this.phoneNumber,
    required this.fcm,
    required this.alertNotification,
    required this.ruleBasedNotification,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        uid: map['Uid'] ?? '',
        email: map['Email'] ?? '',
        name: map['Name'] ?? '',
        organizationID: map['OrganizationID'] ?? '',
        phoneNumber: map['PhoneNumber'] ?? '',
        fcm: map['FCM'] ?? '',
        alertNotification: map['AlertNotification'] ?? true,
        ruleBasedNotification: map['RuleBasedNotification'] ?? false);
  }
}
