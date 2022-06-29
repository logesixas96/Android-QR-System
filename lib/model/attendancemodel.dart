class AttendanceModel{
  String? email;
  String? firstName;
  String? lastName;
  String? phoneNum;
  String? timeStamp;

  AttendanceModel({this.email, this.firstName, this.lastName, this.phoneNum, this.timeStamp});

  //data from server
  factory AttendanceModel.fromMap(map){
    return AttendanceModel(
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNum: map['phoneNum'],
      timeStamp: map['timeStamp'],
    );
  }

  //sending data to server
  Map<String, dynamic> toMap(){
    return{
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNum': phoneNum,
      'timeStamp': timeStamp,
    };
  }
}