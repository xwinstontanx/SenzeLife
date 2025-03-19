class Device {
  String? docID;
  String? deviceEui;
  String? address;
  String? mainUser;
  String? createdAt;
  String? notification;
  String? wakeTime1;
  String? wakeTime2;
  String? bedTime1;
  String? bedTime2;
  String? movement;
  bool? status;
  String? lastStatus;
  String? lastRecordedAt; // For display
  bool? noData;

  Device(
      {this.docID,
      this.deviceEui,
      this.address,
      this.mainUser,
      this.createdAt,
      this.notification,
      this.wakeTime1,
      this.wakeTime2,
      this.bedTime1,
      this.bedTime2,
      this.lastStatus,
      this.status,
      this.movement,
      this.lastRecordedAt,
      this.noData});
}
