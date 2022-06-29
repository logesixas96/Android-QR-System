class HistoryModel{
  String? eventName;
  String? eventAddress;
  String? timeStamp;

  HistoryModel({this.eventName, this.eventAddress, this.timeStamp});

  //data from server
  factory HistoryModel.fromMap(map){
    return HistoryModel(
      eventName: map['eventName'],
      eventAddress: map['eventAddress'],
      timeStamp: map['timeStamp'],

    );
  }

  //sending data to server
  Map<String, dynamic> toMap(){
    return{
      'eventName': eventName,
      'eventAddress': eventAddress,
      'timeStamp': timeStamp,

    };
  }
}