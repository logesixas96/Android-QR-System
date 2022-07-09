class HistoryModel {
  String? eventName;
  String? eventAddress;
  DateTime? timeStamp;

  HistoryModel({this.eventName, this.eventAddress, this.timeStamp});

  factory HistoryModel.fromMap(map) {
    return HistoryModel(
        eventName: map['eventName'],
        eventAddress: map['eventAddress'],
        timeStamp: map['timeStamp']);
  }

  Map<String, dynamic> toMap() {
    return {'eventName': eventName, 'eventAddress': eventAddress, 'timeStamp': timeStamp};
  }
}
